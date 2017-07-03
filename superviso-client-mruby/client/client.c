/*
 * mrbc -Bclient_bytecode  -oclient_bytecode.c client.rb
 * gcc  -I../include client.c  ../build/host/lib/libmruby.a  -o client_bytecode -lm -lonig
 *
 */

#include <mruby.h>
#include <mruby/irep.h>
#include <mruby/proc.h>

#include "client_bytecode.c"

int main(void)
{
    struct mrb_parser_state *p;
    mrb_state *mrb = mrb_open();

    mrb_irep* irep = mrb_read_irep(mrb, client_bytecode);
//    mrb_irep *irep = mrb_add_irep(mrb);
    mrb_run(mrb, mrb_proc_new(mrb, irep), mrb_top_self(mrb));

    mrb_close(mrb);

    return 0;
}
