class fifo_driver;

    mailbox gen2drv;
    virtual fifo_if vif;

    int num_transactions;


    function new(
        mailbox gen2drv,
        virtual fifo_if vif,
        int num_transactions
    );

        this.gen2drv = gen2drv;
        this.vif = vif;
        this.num_transactions = num_transactions;

    endfunction


    task run();

        fifo_transaction trans;

        repeat (num_transactions) begin

            // Get transaction
            gen2drv.get(trans);


            // Drive inputs at falling edge
            @(negedge vif.clk);


            // Drive requested FIFO operation
            vif.wr_en <= trans.wr_en;
            vif.rd_en <= trans.rd_en;
            vif.din   <= trans.data;


            // FIFO processes at next rising edge
            @(posedge vif.clk);


            // Allow DUT NBA updates to complete
            #1;


            // Tell monitor transaction is complete
            -> vif.transaction_done;


            // Return controls to idle
            vif.wr_en <= 1'b0;
            vif.rd_en <= 1'b0;

        end

    endtask

endclass
