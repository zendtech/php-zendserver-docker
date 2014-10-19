#define _POSIX_C_SOURCE 2

#include <stdio.h>
#include <signal.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <mysql/mysql.h>

/** How much time to wait between cycles */
#define MY_SLEEP_SECONDS 1

/** How much time MySQL connection can sleep before killing it */
#define MAX_SLEEP_TIME 3

/**
 * \brief Program params
 *
 * Structure that holds parsed params of program.
 */
typedef struct Params_t {
    const char *mysql_hostname; /**< MySQL hostname */
    unsigned int mysql_port;    /**< MySQL port */
    const char *mysql_username; /**< MySQL username */
    const char *mysql_password; /**< MySQL password */
    const char *mysql_dbname;   /**< MySQL database name */
    int server_id;                /**< ZS node ID */
    const char *web_api_key_name; /**< ZS WebAPI key name */
    const char *web_api_key;      /**< ZS WebAPI key hash */
} Params;

/**
 * \brief Signal handler
 *
 * Handler function for SIGTERM signal.
 * \param sig signal that was received.
 */
void term_handler(int sig);

/**
 * \brief Print MySQL error and exit.
 *
 * Print MySQL error on stderr, close MySQL connection, free memory and exit.
 */
void finish_with_error();

/**
 * \brief Print MySQL error.
 *
 * Print MySQL error on stderr.
 */
void print_mysql_error();

/**
 * \brief Print usage information
 *
 * Print usage information.
 */
void usage(const char *program_name);

/** MySQL connection */
MYSQL mysql;
/** Buffer for all sorts of MySQL queries */
char *query;
/** Parsed program parameters */
Params params;

int main(int argc, const char *argv[])
{
    /* Initialize all query strings */
    const char *create_schema = "CREATE SCHEMA IF NOT EXISTS %s;";
    const char *create_table = "CREATE TABLE IF NOT EXISTS %s.zend_cf_remove_servers(id INTEGER);";
    const char *select_remove_servers = "SELECT id FROM %s.zend_cf_remove_servers;";
    const char *delete_server = "DELETE FROM %s.zend_cf_remove_servers WHERE id = %d;";
    
    /* Check that number of parameters is correct */
    if(argc == 1) {             /* No params = do nothing */
        while(true) {
            int status;
            sleep(10 * MY_SLEEP_SECONDS);
            waitpid(-1,&status,WNOHANG);
        }
    }
    if(argc != 9) {
        usage(argv[0]);
        exit(1);
    }

    /* Allocate memory for query buffer */
    if((query = malloc(sizeof(char) * 1024)) == NULL) {
        exit(3);
    }

    /* Parse prgram arguments */
    params.mysql_hostname = argv[1];
    params.mysql_port = atoi(argv[2]);
    params.mysql_username = argv[3];
    params.mysql_password = argv[4];
    params.mysql_dbname = argv[5];
    params.server_id = atoi(argv[6]);
    params.web_api_key_name = argv[7];
    params.web_api_key = argv[8];

    /* Setup signal handler */
    signal(SIGTERM, term_handler);

    /* Initialize MySQL connection */
    mysql_init(&mysql);
    my_bool recon = true;
    mysql_options(&mysql,MYSQL_OPT_RECONNECT,&recon); /* Set option to auto
                                                       * restart mysql connection */
    if(mysql_real_connect(&mysql,params.mysql_hostname,params.mysql_username,params.mysql_password,NULL,params.mysql_port,NULL,CLIENT_REMEMBER_OPTIONS) == NULL) {
        finish_with_error();
    }

    /* Create schema if needed */
    sprintf(query,create_schema,params.mysql_dbname);
    if(mysql_query(&mysql,query))
        print_mysql_error();
    /* Create table that will hold IDs of ZS nodes to remove */
    sprintf(query,create_table,params.mysql_dbname);
    if(mysql_query(&mysql,query))
        print_mysql_error();

    MYSQL_RES *result;
    MYSQL_ROW row;
    int status;
    int server_id;
    while(true) {               /* Loop forever */
        /* Query server IDs that should be removed */
        sprintf(query,select_remove_servers,params.mysql_dbname);
        if(mysql_query(&mysql,query)) {
            print_mysql_error();
        } else {
            result = mysql_store_result(&mysql);
            while((row = mysql_fetch_row(result))) {
                /* Delete server from Zend Server cluster by calling zs-manage */
                server_id = atoi(row[0]);
                sprintf(query,"/usr/local/zend/bin/zs-manage cluster-remove-server %d -N %s -K %s -f",server_id,params.web_api_key_name,params.web_api_key);
                fprintf(stderr,"%s\n",query);
                /* If call to zs-manage failed, print FAILED on stderr */
                if(system(query) == -1) {
                    fprintf(stderr,"FAILED\n");
                }
                /* Delete server ID from table */
                sprintf(query,delete_server,params.mysql_dbname,server_id);
                if(mysql_query(&mysql,query)) {
                    print_mysql_error();
                }
            }
        }
        /* waitpid call to prevent zombie processes */
        waitpid(-1,&status,WNOHANG);
        sleep(MY_SLEEP_SECONDS);
    }
}

void finish_with_error()
{
    fprintf(stderr, "%s\n", mysql_error(&mysql));
    mysql_close(&mysql);
    free(query);
    exit(2);
}

void print_mysql_error()
{
    fprintf(stderr, "%s\n", mysql_error(&mysql));
}

void term_handler(int sig)
{
    /* Disable signal handlers if more signals come */
    signal(sig,SIG_IGN);
    /* Insert ZS node ID into table of nodes that should be removed from cluster */
    sprintf(query,"INSERT INTO %s.zend_cf_remove_servers(id) VALUES(%d);",params.mysql_dbname,params.server_id);
    mysql_query(&mysql,query);
    /* Clean up and exit */
    mysql_close(&mysql);
    free(query);
    system("/usr/local/zend/bin/zendctl.sh stop");
    exit(0);
}

void usage(const char *program_name)
{
    printf("Usage:\n");
    printf("%s <mysql-hostname> <mysql-port> <mysql-username> <mysql-password> <mysql-db-name> <server-id> <web-api-key-name> <web-api-key>\n",program_name);
}
