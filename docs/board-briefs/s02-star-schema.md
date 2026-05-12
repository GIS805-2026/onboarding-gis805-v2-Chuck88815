# S02 Board Brief - Star Schema

## CEO Question

Which star schema makes the CEO sales question repeatable and reliable each month?

## Recommendation

Use `fact_sales` as the first NexaMart fact table at the sales-line grain. One row represents one sold product line, identified by `order_number` and `sale_line_id`. This grain keeps enough detail to analyze revenue and units by product category, store region, customer, channel, and time period.

## Model

The S02 star schema uses five conformed dimensions around `fact_sales`:

- `dim_product` for category, subcategory, brand, and product attributes.
- `dim_store` for region, province, city, and store type.
- `dim_customer` for customer and loyalty attributes.
- `dim_channel` for sales channel.
- `dim_date` for month, quarter, and year analysis.

The diagram is documented in `docs/schema-v1.md`, with Mermaid source in `diagrams/schema-v1.mmd`.

## Proof

The proof query in `sql/analysis/s02-first-answer.sql` groups `fact_sales` by product category, store region, year, and quarter. It returns total revenue, total units, and sales-line count, which proves that the star schema can answer the CEO question without returning to the raw transaction table.

The first results show the model can compare category-region-quarter combinations such as Automotive in Ontario, Pet Supplies in Quebec, and Books & Media in Quebec/Ontario.

## Decision

The grain is intentionally lower than the order header because an order can contain multiple products. Keeping the sales-line grain preserves product category analysis while still allowing order-level reporting through aggregation.

## Risk

This S02 model covers sales only. It does not yet explain declines using returns, budgets, inventory, or delivery performance. Those later facts should reuse shared dimensions where possible so the board can compare sales with operational causes.
