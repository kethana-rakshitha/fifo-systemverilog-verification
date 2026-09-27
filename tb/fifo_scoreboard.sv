class fifo_scoreboard;

    mailbox mon2scb;

    int num_transactions;

    int pass_count = 0;
    int fail_count = 0;
    int transaction_count = 0;


    // =====================================================
    // REFERENCE FIFO
    // =====================================================

    logic [7:0] reference_queue[$];


    // =====================================================
    // CONSTRUCTOR
    // =====================================================

    function new(
        mailbox mon2scb,
        int num_transactions
    );

        this.mon2scb = mon2scb;
        this.num_transactions = num_transactions;

    endfunction


    // =====================================================
    // SCOREBOARD
    // =====================================================

    task run();

        fifo_transaction trans;

        logic [7:0] expected_data;


        repeat (num_transactions) begin

            // Get transaction

            mon2scb.get(trans);

            transaction_count++;


            // =================================================
            // READ
            // =================================================

            if (trans.read_valid) begin

                if (reference_queue.size() == 0) begin

                    $display(
                        "READ ERROR: Reference FIFO is empty"
                    );

                    fail_count++;

                end

                else begin

                    // FIFO expected output

                    expected_data =
                        reference_queue.pop_front();


                    // Compare actual output

                    if (trans.read_data == expected_data) begin

                        pass_count++;

                        $display(
                            "READ PASS: Expected=%0d Actual=%0d",
                            expected_data,
                            trans.read_data
                        );

                    end

                    else begin

                        fail_count++;

                        $display(
                            "READ FAIL: Expected=%0d Actual=%0d",
                            expected_data,
                            trans.read_data
                        );

                    end

                end

            end


            // =================================================
            // WRITE
            // =================================================

            if (trans.write_valid) begin

                reference_queue.push_back(trans.data);

                $display(
                    "WRITE: Data=%0d Queue_Size=%0d",
                    trans.data,
                    reference_queue.size()
                );

            end


            // =================================================
            // COMPLETELY REJECTED OPERATION
            // =================================================

            if (!trans.write_valid && !trans.read_valid) begin

                $display(
                    "IGNORED: FIFO rejected operation"
                );

            end

        end


        // =====================================================
        // SUMMARY
        // =====================================================

        $display("========================================");
        $display("         FIFO SCOREBOARD SUMMARY        ");
        $display("========================================");

        $display(
            "Total Transactions : %0d",
            transaction_count
        );

        $display(
            "PASS               : %0d",
            pass_count
        );

        $display(
            "FAIL               : %0d",
            fail_count
        );

        $display(
            "Remaining Queue    : %0d",
            reference_queue.size()
        );

        $display("========================================");

    endtask

endclass
