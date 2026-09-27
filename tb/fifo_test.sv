module fifo_test;

    // =====================================================
    // Interface
    // =====================================================

    fifo_if vif();


    // =====================================================
    // DUT
    // =====================================================

    fifo dut (

        .clk   (vif.clk),
        .rst   (vif.rst),

        .wr_en (vif.wr_en),
        .rd_en (vif.rd_en),

        .din   (vif.din),
        .dout  (vif.dout),

        .full  (vif.full),
        .empty (vif.empty)

    );


    // =====================================================
    // Environment
    // =====================================================

    fifo_environment env;

    int num_transactions = 100;


    // =====================================================
    // Clock Generation
    // =====================================================

    initial begin

        vif.clk = 1'b0;

        forever #5 vif.clk = ~vif.clk;

    end


    // =====================================================
    // Test
    // =====================================================

    initial begin

        // Initialize signals

        vif.rst   = 1'b1;
        vif.wr_en = 1'b0;
        vif.rd_en = 1'b0;
        vif.din   = 8'b0;


        // Hold reset for two clock cycles

        repeat (2)
            @(posedge vif.clk);


        // Release reset

        vif.rst = 1'b0;


        // Create environment

        env = new(
            vif,
            num_transactions
        );


        // Start verification environment

        env.run();


        // Finish simulation

        $finish;

    end

endmodule
