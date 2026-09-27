class fifo_generator;

    mailbox gen2drv;

    int num_transactions;


    function new(
        mailbox gen2drv,
        int num_transactions
    );

        this.gen2drv = gen2drv;
        this.num_transactions = num_transactions;

    endfunction


    task run();

        fifo_transaction trans;

        int transaction_id = 0;


        repeat (num_transactions) begin

            transaction_id++;

            trans = new();


            // =================================================
            // TRANSACTION 1
            // Force MAXIMUM data
            // =================================================

            if (transaction_id == 1) begin

                assert(
                    trans.randomize() with {
                        data == 8'd255;
                    }
                )
                else
                    $fatal(
                        "Randomization failed for MAX data"
                    );

            end


            // =================================================
            // TRANSACTION 2
            // Force READ + WRITE
            // =================================================

            else if (transaction_id == 2) begin

                assert(
                    trans.randomize() with {
                        wr_en == 1'b1;
                        rd_en == 1'b1;
                    }
                )
                else
                    $fatal(
                        "Randomization failed for READ + WRITE"
                    );

            end


            // =================================================
            // TRANSACTIONS 3 - 10
            // FORCE WRITE
            //
            // This fills the FIFO and reaches FULL.
            // =================================================

            else if (transaction_id <= 10) begin

                assert(
                    trans.randomize() with {
                        wr_en == 1'b1;
                        rd_en == 1'b0;
                    }
                )
                else
                    $fatal(
                        "Randomization failed for FULL coverage"
                    );

            end


            // =================================================
            // REMAINING TRANSACTIONS
            // Normal random stimulus
            // =================================================

            else begin

                assert(
                    trans.randomize()
                )
                else
                    $fatal(
                        "FIFO transaction randomization failed"
                    );

            end


            // =================================================
            // SEND TRANSACTION TO DRIVER
            // =================================================

            gen2drv.put(trans);

        end

    endtask

endclass
