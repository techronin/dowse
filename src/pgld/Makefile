CFLAGS ?= -ggdb -Wall -DDEBUG=1 -fPIE -pie -I../libb64/include
CC = gcc
LIBS = -l:libdowse.a -ljemalloc -lhiredis -lnetfilter_queue -lnfnetlink -L../libb64 -lb64


pgld_OBJS = pgld.o stream.o blocklist.o parser.o

all: ${pgld_OBJS}
	${CC} ${CFLAGS} ${LDFLAGS} -o pgld ${pgld_OBJS} -L../libdowse ${LIBS}

.c.o:
	${CC} ${CFLAGS} -I. -I.. -I../libdowse -c $< -o $@

clean:
	rm -f *.o
	rm -f pgld
