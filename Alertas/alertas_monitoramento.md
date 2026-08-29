# Alertas de Monitoramento

Este documento descreve os alertas criados para monitoramento de indicadores relacionados à memória, concorrência e utilização do TempDB.

---

## Page Life Expectancy (PLE)

O **Page Life Expectancy** indica, em segundos, por quanto tempo uma página permanece em média no Buffer Pool antes de ser removida.

Um valor baixo ou uma queda significativa pode indicar aumento na atividade de leitura, churn no Buffer Pool ou possível pressão de memória.

O alerta é configurado para ser disparado quando o PLE ficar abaixo do threshold definido.

### Objetivo

- Identificar possíveis sinais de pressão de memória.
- Detectar quedas relevantes na permanência das páginas no Buffer Pool.
- Notificar o administrador para análise do workload e consumo de memória.

> O PLE deve ser analisado em conjunto com outros indicadores. Um valor isolado abaixo do threshold não representa necessariamente um problema de memória.

---

## Deadlock Detectado

Um **deadlock** ocorre quando duas ou mais sessões bloqueiam recursos umas das outras, formando uma dependência circular.

Quando isso acontece, o SQL Server escolhe uma das transações como vítima, encerra sua execução e permite que as demais continuem.

O alerta monitora o contador:

```text
SQLServer:Locks | Number of Deadlocks/sec
```

Quando um deadlock é identificado, uma notificação é enviada ao operador configurado.

### Objetivo

- Detectar rapidamente a ocorrência de deadlocks.
- Notificar o administrador sobre possíveis problemas de concorrência.
- Permitir investigação posterior das queries e recursos envolvidos.

A captura detalhada dos eventos pode ser complementada posteriormente com **Extended Events**, utilizando eventos como `xml_deadlock_report`.

---

## Utilização do Espaço do TempDB

O **TempDB** é utilizado por diversas operações internas do SQL Server, incluindo ordenações, operações de hash, tabelas temporárias, version store e outras atividades que necessitam de espaço temporário.

Nesta versão do monitoramento, o alerta não considera apenas o tamanho absoluto dos arquivos. A condição é baseada no **percentual de espaço utilizado**, permitindo avaliar o consumo em relação à capacidade atualmente disponível no TempDB.

### Métrica monitorada

O alerta calcula o percentual de utilização do espaço dos arquivos de dados do TempDB:

```text
Percentual utilizado = Espaço utilizado / Espaço total × 100
```

A condição de alerta é acionada quando o percentual utilizado ultrapassa o threshold definido.

Essa abordagem torna o monitoramento mais proporcional à capacidade configurada. Um TempDB com arquivos maiores, por exemplo, não precisa ser tratado da mesma forma que um TempDB menor apenas porque ambos atingiram o mesmo número absoluto de MB utilizados.

### Objetivo

- Detectar utilização elevada do espaço disponível no TempDB.
- Identificar situações em que o consumo temporário está se aproximando da capacidade configurada.
- Monitorar o comportamento do workload sem depender exclusivamente do tamanho absoluto dos arquivos.
- Chamar atenção para possíveis spills, operações de `SORT` ou `HASH`, uso intensivo de tabelas temporárias, version store ou outras atividades que utilizam espaço temporário.

> Um percentual elevado de utilização não significa, isoladamente, que exista um problema. O alerta deve ser utilizado como indicador para investigação do workload e das estruturas que estão consumindo espaço no TempDB.

