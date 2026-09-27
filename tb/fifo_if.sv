interface fifo_if;

    // =====================================================
    // FIFO SIGNALS
    // =====================================================

    logic       clk;
    logic       rst;

    logic       wr_en;
    logic       rd_en;

    logic [7:0] din;
    logic [7:0] dout;

    logic       full;
    logic       empty;


    // =====================================================
    // DRIVER → MONITOR SYNCHRONIZATION
    // =====================================================

    event transaction_done;


    // =====================================================
    // ASSERTIONS
    // =====================================================


    // -----------------------------------------------------
    // Assertion 1:
    // FIFO cannot be FULL and EMPTY simultaneously.
    //
    // Disabled during reset.
    // -----------------------------------------------------

    property p_not_full_and_empty;

        @(posedge clk)
        disable iff (rst)
        !(full && empty);

    endproperty


    assert property (p_not_full_and_empty)

        else $error(
            "ASSERTION FAILED: FIFO is FULL and EMPTY simultaneously"
        );


    // -----------------------------------------------------
    // Assertion 2:
    // After reset, FIFO must become EMPTY.
    // -----------------------------------------------------

    property p_reset_empty;

        @(posedge clk)
        rst |=> empty;

    endproperty


    assert property (p_reset_empty)

        else $error(
            "ASSERTION FAILED: FIFO is not EMPTY after reset"
        );


    // -----------------------------------------------------
    // Assertion 3:
    // If FIFO is EMPTY and ONLY a READ is requested,
    // the FIFO must remain EMPTY.
    //
    // IMPORTANT:
    // We exclude wr_en because:
    //
    // EMPTY + READ + WRITE
    //
    // means READ is rejected but WRITE is accepted.
    // Therefore FIFO becomes NOT EMPTY.
    // -----------------------------------------------------

    property p_empty_stays_empty_on_invalid_read;

        @(posedge clk)
        disable iff (rst)
        (empty && rd_en && !wr_en) |=> empty;

    endproperty


    assert property (p_empty_stays_empty_on_invalid_read)

        else $error(
            "ASSERTION FAILED: FIFO left EMPTY after invalid READ"
        );


endinterface
