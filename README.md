# JB Faturamento - dbt Project

## Overview

This dbt project transforms billing and invoicing data from SAP ERP systems into a comprehensive data warehouse for Equatorial Energia. The project processes billing documents, consumption data, and financial transactions to provide insights into revenue, customer billing, and operational metrics.

## How to run this project

```bash

#For CEMAR, CELPA, CEPISA, CEAL and CEA
dbt run --vars "{'source_param': 'eqtl_ma', 'source_orig': 'ccs_ma'}"

#For CEEE
dbt run --vars "{'source_param': 'eqtl_rs_eqz', 'source_orig': 'ccs_rs', 'database_prd': 'eqtlinfo_hml'}"

```

## Project Structure

```
jb_faturamento/
├── models/
│   ├── staging/          # Raw data models with minimal transformations
│   ├── intermediate/     # Complex business logic and data preparation
│   └── marts/           # Final presentation layer for business users
├── macros/              # Reusable SQL logic and utilities
├── tests/               # Data quality tests and assertions
├── seeds/               # Static reference data
├── snapshots/           # Slowly changing dimension tracking
└── analyses/            # Ad-hoc analyses and investigations
```

## Key Models

### Marts Layer

- `faturamento`: Main billing fact table
- `itens_faturamento`: Billing line items
- `rel_faturamento_leitura`: Billing vs. reading reconciliation
