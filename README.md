# JB Faturamento - dbt Project

## Overview

This dbt project transforms billing and invoicing data from SAP ERP systems into a comprehensive data warehouse for Equatorial Energia. The project processes billing documents, consumption data, and financial transactions to provide insights into revenue, customer billing, and operational metrics.

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

## Data Sources

### RAW Schema (eqtlinfo_raw)

- **ERDK**: Billing document header data
- **ERCHC**: Billing document item data
- **ERCH**: Billing document master data
- **DBERCHZ1-7**: Various billing document extensions
- **ETDZ, ETRG, ETTIFN**: Technical and operational data
- **ZCFAT*IRREG*\***: Irregular billing data

### PROD Schema (eqtlinfo_prd)

- **FATURAMENTO**: Main billing table
- **FATURAMENTO_OPERACOES**: Billing operations
- **TAB_CONTROLE_CARGAS**: Load control table
- **INT_ULTIMA_EXECUCAO**: Last execution tracking

## Key Models

### Staging Layer

- `stg_erdk_fat`: Billing document headers
- `stg_erchc_fat`: Billing document items
- `stg_erch_fat`: Billing document master data

### Intermediate Layer

- `int_documentos_faturamento`: Document processing and classification
- `int_estornados_delta`: Reversal document processing
- `int_consumo_delta`: Consumption data processing
- `faturamento_delta`: Incremental billing data

### Marts Layer

- `faturamento`: Main billing fact table
- `itens_faturamento`: Billing line items
- `rel_faturamento_leitura`: Billing vs. reading reconciliation

## Configuration

### Environment Variables

- `source_param`: Source system identifier (EQTL_AP, EQTL_MA, etc.)
- `source_orig`: Original source system (CCS_AP, CCS_MA, etc.)
- `dia_fim`: End date for processing (defaults to today)

### Materialization Strategy

- **Staging**: Views (for performance and freshness)
- **Intermediate**: Tables (for complex transformations)
- **Marts**: Tables (for end-user consumption)

## Usage

### Running the Project

```bash
# Install dependencies
dbt deps

# Run all models
dbt run

# Run specific model
dbt run --select staging
dbt run --select intermediate
dbt run --select marts

# Run with specific tags
dbt run --select tag:billing

# Test data quality
dbt test

# Generate documentation
dbt docs generate
dbt docs serve
```

### Incremental Processing

The main `faturamento` model uses incremental processing to only process new or changed records. The incremental strategy is configured to use `merge_insert_only` for optimal performance.

### Data Freshness

Source tables are configured with freshness checks:

- **Warning**: 12 hours
- **Error**: 24 hours

## Testing Strategy

### Generic Tests

- `unique`: Ensures primary key uniqueness
- `not_null`: Validates required fields
- `relationships`: Checks referential integrity

### Custom Tests

- `assert_unique_faturamento`: Validates billing document uniqueness
- `assert_unique_erchc`: Ensures document relationship integrity
- `assert_categoria_tarifa`: Validates tariff category logic

## Macros

### Business Logic Macros

- `mc_mandante()`: Maps source parameters to client codes
- `colunas_faturamento_pial()`: Adds PIAL-specific columns
- `merge_estornados()`: Handles reversal document processing
- `update_reversao()`: Updates reversal status

### Utility Macros

- `select_cols_fat()`: Standard column selection
- `select_itens()`: Item selection logic
- `merge_insert_only()`: Incremental merge strategy

## Data Quality

### Source Data Validation

- Freshness checks on all source tables
- Primary key validation
- Referential integrity checks

### Business Rule Validation

- Billing document uniqueness
- Tariff category consistency
- Consumption vs. billing reconciliation

## Performance Considerations

### Optimization Strategies

- Incremental processing for large tables
- Appropriate materialization strategies
- Efficient join patterns in intermediate models

### Monitoring

- Model execution times
- Data freshness alerts
- Test failure notifications

## Contributing

### Development Guidelines

1. Follow SQLFluff formatting standards
2. Add comprehensive documentation for new models
3. Include appropriate tests for data quality
4. Use descriptive naming conventions
5. Tag models appropriately for organization

### Code Review Checklist

- [ ] Model has proper documentation
- [ ] Tests are included and comprehensive
- [ ] SQL follows formatting standards
- [ ] Performance considerations addressed
- [ ] Business logic is clear and well-commented

## Support

For questions or issues related to this dbt project, please contact the data engineering team or create an issue in the project repository.

## Version History

- **v2.5.0**: Current version with incremental processing and comprehensive testing
- **v2.4.0**: Added PIAL-specific functionality
- **v2.3.0**: Implemented incremental processing
- **v2.2.0**: Added data quality tests
- **v2.1.0**: Initial release with basic billing transformations
