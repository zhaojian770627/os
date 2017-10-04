#include <linux/module.h>

#include <linux/kernel.h>
#include <linux/sched.h>
#include <linux/timer.h>
#include <linux/fs.h>
#include <linux/poll.h>
#include <linux/proc_fs.h>
#include <linux/io.h>

#include "schar.h"

/* forward declarations for _fops */
static ssize_t schar_read(struct file *file,char *buf,size_t count,loff_t *offset);
static ssize_t sxhar_write(struct file *file,const char *buf,size_t count,loff_t *offset);
static unsigned int schar_pool(struct file *file,poll_table *wait);
static int schar_ioctl(struct inode *inode,struct file *file,unsigned int cmd,unsigned long arg);
static int schar_mmap(struct file *file,struct vm_area_struct *vma);
static int schar_open(struct inode *inode,struct file *file);
static int schar_release(struct inode *inode,struct file *file);


int init_module(void)
{
}

void cleanup_module(void)
{
}
