-- Create two tables we are going to import of csv data into

USE project;
CREATE TABLE superstores_sales (product_id INT,
                                invoice_date date,
                                state VARCHAR(30),
                                market_size VARCHAR(30),
								product_type VARCHAR(15),
                                caffeine_type VARCHAR(15),
                                sales INT,
                                cogs INT,
                                total_expenses INT,
                                marketing INT,
                                inventory INT,
                                budget_cogs INT,
                                budget_sales INT);
                                
USE project;
CREATE TABLE drink_sales (product_id INT,
						   invoice_date date,
                           product_type VARCHAR(15),
                           product_description VARCHAR(50));
                           
-- Import data from CSV files by using Table Data Import Wizard
                           