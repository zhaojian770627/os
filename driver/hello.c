#include <linux/module.h>
#include <linux/kernel.h>

int init_module(void)
{
  printk(KERN_DEBUG "Hello,kernel!\n");
  return 0;
}

void cleanup_module(void)
{
  printk(KERN_DEBUG "Good-bye,kernel!\n");
}
