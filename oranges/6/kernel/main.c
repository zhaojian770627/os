PUBLIC int kernel_main()
{
  disp_str("-----\"kernel_main\" begins-------\n");
  /* TODO */


  while(1){
  }
}

void TestA()
{
  int i=0;
  while(1){
    disp_str("A");
    disp_int(i++);
    disp_str(".");
    delay(1);
  }
}
