import json
import pandas as pd
import subprocess
import os
import shutil

def run_dbt_freshness_and_get_results(dbt_project_dir, empresa_name, dbt_vars):
    """
    Executa 'dbt source freshness' para uma empresa e retorna o conteúdo JSON de target/sources.json.
    """
    vars_json_str = json.dumps(dbt_vars)
    command = ['dbt', 'source', 'freshness', '--vars', vars_json_str]
    
    print(f"\n>> Processando {empresa_name}...")
    print(f"   Executando comando: {' '.join(command)}")
    
    try:
        process = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=False, 
            cwd=dbt_project_dir,
            encoding='utf-8'
        )

        if process.returncode != 0:
            print(f"   AVISO: dbt para {empresa_name} concluiu com código {process.returncode} (geralmente indica 'stale' ou alertas).")
        else:
            print(f"   Execução do dbt para {empresa_name} concluída.")

        if process.stderr: # Exibe mensagens de erro/alerta do dbt, se houver.
            print(f"   --- Mensagens do dbt (stderr) para {empresa_name} ---")
            print(process.stderr.strip())
            print(f"   --- Fim das mensagens do dbt ---")

        sources_json_path = os.path.join(dbt_project_dir, 'target', 'sources.json')
        if not os.path.exists(sources_json_path):
            print(f"   ERRO CRÍTICO: 'target/sources.json' NÃO FOI ENCONTRADO para {empresa_name} após a execução do dbt.")
            if process.stdout:
                print(f"   --- Saída completa do dbt (stdout) para {empresa_name} ---")
                print(process.stdout.strip())
                print(f"   --- Fim da saída completa do dbt ---")
            return None
            
        with open(sources_json_path, 'r', encoding='utf-8') as f:
            json_content = json.load(f)
        
        return json_content

    except FileNotFoundError:
        print(f"ERRO FATAL: Comando 'dbt' não encontrado. Verifique a instalação e o PATH do sistema.")
        raise 
    except Exception as e:
        print(f"ERRO Inesperado ao processar {empresa_name}: {e}")
        return None

def parse_freshness_data_from_json(json_content, empresa_name):
    """
    Analisa o conteúdo JSON de um artefato sources.json e extrai dados de freshness.
    """
    data = []
    if not json_content or 'results' not in json_content:
        print(f"   AVISO: Conteúdo JSON de {empresa_name} inválido ou sem a chave 'results'.")
        return data

    results = json_content.get('results', [])
    for res in results:
        unique_id = res.get('unique_id', '')
        unique_id_parts = unique_id.split('.')
        
        source_yml_name = unique_id_parts[2] if len(unique_id_parts) > 2 else "N/A"
        table_name = '.'.join(unique_id_parts[3:]) if len(unique_id_parts) > 3 else "N/A"

        # Usando 'max_loaded_at_time_ago_in_s' conforme fornecido no seu script.
        age_seconds = res.get('max_loaded_at_time_ago_in_s')
        age_hours = round(age_seconds / 3600, 2) if age_seconds is not None else None

        criteria = res.get('criteria', {})
        warn_after_obj = criteria.get('warn_after', {})
        error_after_obj = criteria.get('error_after', {})

        warn_after_str = f"{warn_after_obj.get('count')} {warn_after_obj.get('period', '')}".strip() if warn_after_obj.get('count') else "N/A"
        error_after_str = f"{error_after_obj.get('count')} {error_after_obj.get('period', '')}".strip() if error_after_obj.get('count') else "N/A"
        
        max_loaded_at_ts = res.get('max_loaded_at')
        snapshotted_at_ts = res.get('snapshotted_at')

        data.append({
            'Empresa': empresa_name,
            'Source (do YML)': source_yml_name,
            'Table Name': table_name,
            'Status': res.get('status'),
            'Age (Horas)': age_hours,
            'Max Loaded At': max_loaded_at_ts,
            'Snapshotted At': snapshotted_at_ts,
            'Warn After': warn_after_str,
            'Error After': error_after_str,
            'Execution Time (s)': res.get('execution_time'),
            'Unique ID': unique_id,
            'Filter Criteria': str(criteria.get('filter'))
        })
    return data

def main():
    dbt_project_dir = os.getcwd()
    print(f"Usando diretório do projeto dbt: {dbt_project_dir}")

    empresas_config = [
        {'name': 'Maranhão', 'vars': {'source_orig': 'CCS_MA', 'source_param': 'EQTL_MA'}},
        {'name': 'Pará',     'vars': {'source_orig': 'CCS_PA', 'source_param': 'EQTL_PA'}},
        {'name': 'Piauí',    'vars': {'source_orig': 'CCS_PI', 'source_param': 'EQTL_PI'}},
        {'name': 'Alagoas',  'vars': {'source_orig': 'CCS_AL', 'source_param': 'EQTL_AL'}},
    ]

    all_freshness_data = []

    for config in empresas_config:
        empresa_name = config['name']
        dbt_vars = config['vars']
        
        sources_json_content = run_dbt_freshness_and_get_results(dbt_project_dir, empresa_name, dbt_vars)
        
        if sources_json_content:
            parsed_data = parse_freshness_data_from_json(sources_json_content, empresa_name)
            if parsed_data:
                all_freshness_data.extend(parsed_data)
                print(f"   Dados de freshness para {empresa_name} processados.")
            else:
                print(f"   Nenhum dado de freshness analisado para {empresa_name}.")
        else:
            print(f"   Falha ao obter dados de freshness para {empresa_name}. Verifique os logs.")

    if not all_freshness_data:
        print("\nNenhum dado de freshness foi coletado. Verifique os logs e as execuções do dbt.")
        return

    df = pd.DataFrame(all_freshness_data)

    def get_status_sort_order(status_string):
        if not status_string: return 3 
        status_lower = status_string.lower()
        if status_lower.startswith('error'): return 0
        if status_lower.startswith('warn'): return 1
        if status_lower.startswith('pass'): return 2
        return 3 

    df['status_sort_key'] = df['Status'].apply(get_status_sort_order)

    df_sorted = df.sort_values(
        by=['status_sort_key', 'Age (Horas)', 'Empresa', 'Source (do YML)', 'Table Name'],
        ascending=[True, False, True, True, True],
        na_position='last' 
    )

    df_sorted = df_sorted.drop(columns=['status_sort_key'])
 
    column_order = [
        'Empresa', 
        'Source (do YML)', 
        'Table Name', 
        'Status',
        'Age (Horas)', 
        'Max Loaded At', 
        'Snapshotted At'
    ]
    
    df_final_for_excel = df_sorted[[col for col in column_order if col in df_sorted.columns]]

    excel_file_name = 'dbt_source_freshness.xlsx'
    try:
        df_final_for_excel.to_excel(excel_file_name, index=False, engine='openpyxl')
        print(f"\nRelatório de freshness consolidado e ordenado salvo com sucesso em: {os.path.join(dbt_project_dir, excel_file_name)}")
    except Exception as e:
        print(f"\nERRO ao salvar o arquivo Excel '{excel_file_name}': {e}")
        print("  Verifique permissões de escrita e se o arquivo não está aberto em outro programa.")

if __name__ == '__main__':
    if shutil.which("dbt") is None:
        print("********************************************************************************")
        print("ATENÇÃO: O comando 'dbt' NÃO FOI ENCONTRADO no PATH do sistema.")
        print("O script NÃO PODERÁ executar os comandos 'dbt source freshness'.")
        print("Por favor, certifique-se de que o dbt está instalado, configurado corretamente,")
        print("e que o ambiente do terminal onde este script é executado tem acesso ao 'dbt'.")
        print("********************************************************************************")
    
    try:
        import pandas
        import openpyxl
    except ImportError:
        print("********************************************************************************")
        print("ATENÇÃO: Bibliotecas Python necessárias (pandas, openpyxl) não encontradas.")
        print("Por favor, instale-as usando o comando: pip install pandas openpyxl")
        print("O script não poderá gerar o arquivo Excel sem estas bibliotecas.")
        print("********************************************************************************")

    main()