class fifo_monitor;

    mailbox mon2scb;
    virtual fifo_if vif;

    int num_transactions;


    // =====================================================
    // FUNCTIONAL COVERAGE
    // =====================================================

    covergroup fifo_coverage with function sample(
        logic        wr_en,
        logic        rd_en,
        logic        full,
        logic        empty,
        logic [7:0]  data
    );

        coverpoint wr_en {

            bins WRITE    = {1'b1};
            bins NO_WRITE = {1'b0};

        }


        coverpoint rd_en {

            bins READ    = {1'b1};
            bins NO_READ = {1'b0};

        }


        coverpoint full {

            bins NOT_FULL = {1'b0};
            bins FULL     = {1'b1};

        }


        coverpoint empty {

            bins NOT_EMPTY = {1'b0};
            bins EMPTY     = {1'b1};

        }


        coverpoint data {

            bins ZERO  = {8'd0};
            bins MAX   = {8'd255};
            bins OTHER = {[8'd1:8'd254]};

        }


        // READ / WRITE cross

        cross wr_en, rd_en {

            ignore_bins idle =
                binsof(wr_en) intersect {1'b0} &&
                binsof(rd_en) intersect {1'b0};

        }


        // FULL / EMPTY cross

        cross full, empty {

            ignore_bins illegal_full_empty =
                binsof(full) intersect {1'b1} &&
                binsof(empty) intersect {1'b1};

        }

    endgroup


    // =====================================================
    // CONSTRUCTOR
    // =====================================================

    function new(
        mailbox mon2scb,
        virtual fifo_if vif,
        int num_transactions
    );

        this.mon2scb = mon2scb;
        this.vif = vif;
        this.num_transactions = num_transactions;

        fifo_coverage = new();

    endfunction


    // =====================================================
    // MONITOR
    // =====================================================

    task run();

        fifo_transaction trans;


        // State before operation

        logic full_before;
        logic empty_before;

        logic wr_en_before;
        logic rd_en_before;

        logic [7:0] din_before;


        repeat (num_transactions) begin


            // Wait for operation clock
            @(posedge vif.clk);


            // Capture state BEFORE operation

            full_before  = vif.full;
            empty_before = vif.empty;

            wr_en_before = vif.wr_en;
            rd_en_before = vif.rd_en;

            din_before   = vif.din;


            // Wait for driver to complete transaction

            @(vif.transaction_done);


            // Create transaction

            trans = new();


            // Store requested operation

            trans.wr_en = wr_en_before;
            trans.rd_en = rd_en_before;

            trans.data = din_before;


            // Capture actual READ data

            trans.read_data = vif.dout;


            // =================================================
            // WRITE ACCEPTANCE
            // =================================================

            trans.write_valid = 1'b0;

            if (wr_en_before && !full_before)
                trans.write_valid = 1'b1;


            // =================================================
            // READ ACCEPTANCE
            // =================================================

            trans.read_valid = 1'b0;

            if (rd_en_before && !empty_before)
                trans.read_valid = 1'b1;


            // =================================================
            // COVERAGE
            // =================================================

            fifo_coverage.sample(
                wr_en_before,
                rd_en_before,
                full_before,
                empty_before,
                din_before
            );


            // Send to scoreboard

            mon2scb.put(trans);

        end

    endtask

endclass
