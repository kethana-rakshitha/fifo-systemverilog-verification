class fifo_environment;

    mailbox gen2drv;
    mailbox mon2scb;

    fifo_generator  gen;
    fifo_driver     drv;
    fifo_monitor    mon;
    fifo_scoreboard scb;

    virtual fifo_if vif;

    int num_transactions;


    function new(
        virtual fifo_if vif,
        int num_transactions
    );

        this.vif = vif;
        this.num_transactions = num_transactions;


        // Create mailboxes
        gen2drv = new();
        mon2scb = new();


        // Create verification components
        gen = new(
            gen2drv,
            num_transactions
        );

        drv = new(
            gen2drv,
            vif,
            num_transactions
        );

        mon = new(
            mon2scb,
            vif,
            num_transactions
        );

        scb = new(
            mon2scb,
            num_transactions
        );

    endfunction


    task run();

        fork

            gen.run();
            drv.run();
            mon.run();
            scb.run();

        join

    endtask

endclass
