/// Copyright (C) strawberryhacker

#include <cinnamon/types.h>
#include <cinnamon/sched.h>
#include <cinnamon/print.h>
#include <cinnamon/thread.h>
#include <stddef.h>

void idle_init(struct rq* rq)
{
    print("Init idle\n");
    rq->idle_rq.idle = NULL;
}

void idle_enqueue(struct thread* thread, struct rq* rq)
{
    rq->idle_rq.idle = thread;
}

struct thread* idle_pick_next(struct rq* rq)
{
    return rq->idle_rq.idle;
}

const struct sched_class idle_class = {
        .next = NULL,
        .init = &idle_init,
        .enqueue = &idle_enqueue,
        .pick_next = &idle_pick_next
};
