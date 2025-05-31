-- Membuat atau menggantikan tabel analysis_table di skema kimia_farma
CREATE OR REPLACE TABLE kimia_farma.analysis_table AS
SELECT 
    t.transaction_id,                             -- ID transaksi dari tabel transaksi
    t.date,                                       -- Tanggal transaksi
    t.branch_id,                                  -- ID cabang tempat transaksi terjadi
    kc.branch_name,                               -- Nama cabang dari tabel kantor cabang
    kc.kota,                                      -- Kota cabang
    kc.provinsi,                                  -- Provinsi cabang
    kc.rating AS rating_cabang,                   -- Rating cabang, dinamai ulang sebagai rating_cabang
    t.customer_name,                              -- Nama pelanggan yang melakukan transaksi
    t.product_id,                                 -- ID produk yang dibeli
    p.product_name,                               -- Nama produk dari tabel produk
    p.price AS actual_price,                      -- Harga asli produk, dinamai ulang sebagai actual_price
    t.discount_percentage,                        -- Persentase diskon yang diberikan pada transaksi

    -- Menentukan presentase laba kotor berdasarkan kisaran harga produk
    CASE
        WHEN p.price <= 50000 THEN 10
        WHEN p.price > 50000 AND p.price <= 100000 THEN 15
        WHEN p.price > 100000 AND p.price <= 300000 THEN 20
        WHEN p.price > 300000 AND p.price <= 500000 THEN 25
        WHEN p.price > 500000 THEN 30
    END AS presentase_gross_laba,

    -- Menghitung penjualan bersih setelah diskon: harga * (1 - diskon%)
    (p.price * (1 - t.discount_percentage/100)) AS nett_sales,

    -- Menghitung laba bersih: penjualan bersih * persentase laba kotor
    (p.price * (1 - t.discount_percentage/100) * 
     CASE
        WHEN p.price <= 50000 THEN 0.10
        WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15
        WHEN p.price > 100000 AND p.price <= 300000 THEN 0.20
        WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25
        WHEN p.price > 500000 THEN 0.30
     END) AS nett_profit,

    t.rating AS rating_transaksi                  -- Rating yang diberikan pada transaksi
FROM 
    kimia_farma.kf_final_transaction t            -- Mengambil data dari tabel transaksi (dengan alias t)
JOIN 
    kimia_farma.kf_product p ON t.product_id = p.product_id          -- Join dengan tabel produk berdasarkan product_id
JOIN 
    kimia_farma.kf_kantor_cabang kc ON t.branch_id = kc.branch_id;   -- Join dengan tabel kantor cabang berdasarkan branch_id
