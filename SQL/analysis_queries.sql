-- ===================================================================
-- Blinkit Sales Analysis - SQL Query Suite
-- Table: blinkit_grocery
-- ===================================================================

-- 1. Table Creation DDL (Reference Schema)
CREATE TABLE IF NOT EXISTS blinkit_grocery (
    item_fat_content VARCHAR(50),
    item_identifier VARCHAR(20),
    item_type VARCHAR(100),
    outlet_establishment_year INT,
    outlet_identifier VARCHAR(20),
    outlet_location_type VARCHAR(50),
    outlet_size VARCHAR(30),
    outlet_type VARCHAR(50),
    item_visibility NUMERIC(10,6),
    item_weight NUMERIC(10,2),
    sales NUMERIC(12,4),
    rating NUMERIC(5,2)
);

-- Quick preview
SELECT * FROM blinkit_grocery LIMIT 10;

-- ===================================================================
-- 2. Data Cleaning: Standardize Item Fat Content values
-- ===================================================================
UPDATE blinkit_grocery
SET item_fat_content = 
    CASE 
        WHEN item_fat_content IN ('LF', 'low fat', 'low_fat') THEN 'Low Fat'
        WHEN item_fat_content IN ('reg', 'regular') THEN 'Regular'
        ELSE item_fat_content
    END;

-- ===================================================================
-- 3. Core Business KPIs
-- ===================================================================

-- 1. TOTAL SALES (in Millions):
SELECT ROUND(SUM(sales) / 1000000.0, 2) AS total_sales_million
FROM blinkit_grocery;

-- 2. AVERAGE SALES:
SELECT ROUND(AVG(sales), 2) AS avg_sales
FROM blinkit_grocery;

-- 3. NUMBER OF ITEMS / ORDERS:
SELECT COUNT(*) AS no_of_orders
FROM blinkit_grocery;

-- 4. AVERAGE RATING:
SELECT ROUND(AVG(rating), 2) AS avg_rating
FROM blinkit_grocery;

-- ===================================================================
-- 4. Granular Business Analysis
-- ===================================================================

-- B. Total Sales by Fat Content:
SELECT 
    item_fat_content, 
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS avg_sales,
    COUNT(*) AS no_of_items,
    ROUND(AVG(rating), 2) AS avg_rating
FROM blinkit_grocery
GROUP BY item_fat_content
ORDER BY total_sales DESC;

-- C. Total Sales by Item Type (Top Product Categories):
SELECT 
    item_type, 
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS avg_sales,
    COUNT(*) AS no_of_items,
    ROUND(AVG(rating), 2) AS avg_rating
FROM blinkit_grocery
GROUP BY item_type
ORDER BY total_sales DESC;

-- D. Fat Content by Outlet Location for Total Sales:
SELECT 
    outlet_location_type,
    COALESCE(
        SUM(CASE 
            WHEN item_fat_content = 'Low Fat' THEN sales 
            ELSE 0 
        END), 0
    ) AS low_fat_sales,
    COALESCE(
        SUM(CASE 
            WHEN item_fat_content = 'Regular' THEN sales 
            ELSE 0 
        END), 0
    ) AS regular_sales,
    ROUND(SUM(sales), 2) AS total_sales
FROM blinkit_grocery
GROUP BY outlet_location_type
ORDER BY outlet_location_type;

-- E. Total Sales by Outlet Establishment Year:
SELECT 
    outlet_establishment_year, 
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS avg_sales,
    COUNT(*) AS no_of_items
FROM blinkit_grocery
GROUP BY outlet_establishment_year
ORDER BY outlet_establishment_year ASC;

-- F. Percentage of Sales by Outlet Size:
SELECT 
    outlet_size, 
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(sales) * 100.0 / (SELECT SUM(sales) FROM blinkit_grocery), 2) AS sales_percentage
FROM blinkit_grocery
GROUP BY outlet_size
ORDER BY total_sales DESC;

-- G. Sales by Outlet Location Tier:
SELECT 
    outlet_location_type, 
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS avg_sales,
    COUNT(*) AS no_of_items
FROM blinkit_grocery
GROUP BY outlet_location_type
ORDER BY total_sales DESC;

-- H. All Metrics by Outlet Type:
SELECT 
    outlet_type, 
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS avg_sales,
    COUNT(*) AS no_of_items,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(item_visibility), 4) AS avg_visibility
FROM blinkit_grocery
GROUP BY outlet_type
ORDER BY total_sales DESC;
