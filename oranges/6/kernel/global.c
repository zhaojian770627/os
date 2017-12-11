#define GLOBAL_VARIABLES_HERE

#include "../include/type.h"
#include "../include/const.h"
#include "../include/protect.h"
#include "../include/proto.h"
#include "../include/proc.h"
#include "../include/global.h"

PUBLIC PROCESS proc_table[NR_TASKS];
PUBLIC	char   task_stack[STACK_SIZE_TOTAL];
