#include <errno.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <sys/time.h>

#include "list.h"
#include "log.h"
#include "util.h"

//#define log printf
//#define debug printf

typedef bool (*timer_callback)(void *data);

struct timer {
	struct list_entry list_entry;
	time_t timeout;
	timer_callback callback;
	void *callback_data;
};

struct timer_manager {
	unsigned int counter;
	struct timer *current;
	struct list list;
};

static void timer_add(unsigned int seconds, timer_callback cb, void *cb_data)
{
	time_t now;
	time_t next;
	struct timer *t;

	t = mem_alloc_zero(sizeof(*t));

	now = time(NULL);

	t->timeout = now + seconds;

	next = alarm(0);

	debug("timeout: %ld -> %ld\n", (long)now, (long)t->timeout);
	debug("next = %lu\n", (long)next);
}

struct sig_events {
	volatile sig_atomic_t alarm;
};

static struct sig_events sig_events = {
	.alarm = 0,
};

static void SIGALRM_handler(int signum)
{
	//debug("SIGALRM\n");
	sig_events.alarm = 1;
	signal(signum, SIGALRM_handler);
}

static void on_sigalrm(void)
{
	time_t now;

	log("-- on_sigalrm --\n");

	now = time(NULL);
	debug("time    = %ld\n", (long)now);

	if (now < 0) {
		log("time failed: %s\n", strerror(errno));
	}

	exit(EXIT_SUCCESS);
}

int main(int argc, char *argv[])
{
	time_t now;
	unsigned int timeout;
	
	signal(SIGALRM, SIGALRM_handler);

	now = time(NULL);
	debug("time    = %ld\n", (long)now);

	if (now < 0) {
		log("time failed: %s\n", strerror(errno));
	}

	timeout = alarm(0);
	debug("timeout = %u\n", timeout);
	
	if (timeout) {
	} else {
		alarm(5);
	}

	while (!sig_events.alarm);

	on_sigalrm();

	return EXIT_FAILURE;
}
