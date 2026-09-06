# SQL Server --- Baseline de Instalação e Configuração

## Objetivo

Este documento apresenta o baseline utilizado para a instalação de uma
instância SQL Server, com foco em uma configuração próxima de um cenário de produção.

A proposta não é apenas instalar o SQL Server, mas estabelecer
previamente uma arquitetura de infraestrutura, armazenamento e
parâmetros do Database Engine que favoreça **previsibilidade,
desempenho, organização e facilidade de manutenção**.

O processo também foi estruturado para permitir que a instalação seja
realizada de forma **automatizada por linha de comando**, utilizando um
arquivo de configuração (`ConfigurationFile.ini`).

------------------------------------------------------------------------

## 1. Organização do ambiente

Um dos pontos considerados no planejamento foi evitar concentrar todos
os arquivos do SQL Server no mesmo volume.

A arquitetura definida separa os principais tipos de carga:

  Volume   Finalidade
  -------- -----------------------------------------------------
  **F:**   Binários e componentes compartilhados do SQL Server
  **G:**   Arquivos de dados
  **H:**   Logs de transações
  **I:**   Backups
  **T:**   TempDB e cargas temporárias

Essa separação permite organizar melhor as operações de I/O e facilita a
administração do ambiente.

A ideia é que dados, logs, backups e TempDB tenham áreas próprias,
evitando que diferentes tipos de operação disputem indiscriminadamente o
mesmo armazenamento.

Além da organização física, o baseline considera o **princípio do menor
privilégio** para as contas de serviço, concedendo acesso somente aos
diretórios necessários para cada componente.

------------------------------------------------------------------------

## 2. TempDB

A configuração da TempDB foi definida previamente no arquivo de
instalação:

``` ini
SQLTEMPDBFILECOUNT="8"
SQLTEMPDBFILESIZE="1000"
SQLTEMPDBFILEGROWTH="512"
SQLTEMPDBLOGFILESIZE="2000"
SQLTEMPDBLOGFILEGROWTH="256"
```

O ambiente utiliza **8 arquivos de dados para a TempDB**, com tamanho
inicial e crescimento configurados explicitamente.

A intenção é evitar depender dos valores padrão do instalador e
estabelecer um comportamento previsível desde a criação da instância.

O crescimento também é definido em valores fixos, evitando depender de
configurações automáticas que poderiam resultar em muitos eventos de
autogrowth ao longo da operação.

A TempDB possui ainda um volume dedicado:

``` text
T:\SQLTemp\
```

Essa decisão está relacionada ao fato de o TempDB ser utilizada por
diversas operações internas e temporárias do SQL Server.

------------------------------------------------------------------------

## 3. Logs de transações

Os logs de transações foram separados fisicamente dos arquivos de dados:

``` text
H:\SQLLogs\
```

Essa separação faz parte do planejamento de armazenamento do ambiente.

O objetivo é evitar que operações de leitura/escrita dos arquivos de
dados e as gravações sequenciais do transaction log dependam
necessariamente do mesmo volume.

Também foi definida uma área específica para os logs do SSAS:

``` text
H:\SQLLogs\SSAS\Log
```

Isso mantém uma organização consistente entre os componentes instalados.

------------------------------------------------------------------------

## 4. Memória

O baseline também estabelece um limite explícito para a memória
utilizada pelo SQL Server:

``` ini
SQLMAXMEMORY="42000"
SQLMINMEMORY="0"
```

O valor de `SQLMAXMEMORY` foi definido para evitar que o SQL Server
tenha liberdade para consumir toda a memória disponível no servidor.

Essa configuração é importante porque o sistema operacional e outros
componentes instalados na máquina também precisam de memória.

A ideia é trabalhar com uma **reserva consciente para o sistema
operacional**, em vez de deixar a gestão de memória depender
exclusivamente do comportamento padrão. 

------------------------------------------------------------------------

## 5. MAXDOP

O parâmetro foi definido como:

``` ini
SQLMAXDOP="8"
```

O `MAXDOP` controla quantos processadores podem ser utilizados por uma
única operação paralela.

A configuração foi incluída no baseline para que o comportamento de
paralelismo da instância seja definido desde a instalação, em vez de
permanecer baseado no valor padrão.

É importante destacar que `MAXDOP` não deve ser analisado isoladamente.
Seu valor precisa considerar a quantidade de CPUs disponíveis, o tipo de
workload e as características do ambiente.

Neste baseline, o valor definido é:

``` text
MAXDOP = 8
```

------------------------------------------------------------------------

## 6. Outras decisões de configuração

O baseline também contempla algumas definições importantes da instância:

-   Nome da instância: `VITALLIS_PROD`
-   Collation: `Latin1_General_CI_AI`
-   SQL Server Agent configurado para inicialização automática
-   TCP/IP habilitado
-   SQL Server Browser desabilitado
-   Instant File Initialization habilitado
-   Serviços configurados com contas específicas
-   Diretórios de dados, logs, backups e arquivos temporários
    previamente definidos

Essas configurações permitem que a instalação já produza uma instância
com uma estrutura inicial padronizada.

------------------------------------------------------------------------

## 7. Instalação por linha de comando

Uma das principais características deste baseline é a possibilidade de
utilizar o arquivo `.ini` como fonte de configuração para o SQL Server
Setup.

O instalador pode ser executado através da linha de comando:

``` powershell
setup.exe /ConfigurationFile="ConfigurationFile.ini"
```

Com isso, parâmetros como:

-   instância;
-   diretórios;
-   contas de serviço;
-   memória;
-   MAXDOP;
-   TempDB;
-   componentes instalados;
-   configuração de rede;

podem ser definidos antecipadamente.

Para uma instalação totalmente automatizada, o modo silencioso pode ser
habilitado no arquivo:

``` ini
QUIET="True"
```

Enquanto uma instalação assistida pode utilizar:

``` ini
QUIET="False"
UIMODE="Normal"
```

A diferença permite utilizar o mesmo conceito de arquivo de configuração
tanto para instalações interativas quanto para processos **unattended**.

------------------------------------------------------------------------

## 8. Objetivo 

A principal ideia deste trabalho é transformar a instalação do SQL
Server em um processo **reprodutível e documentado**.

Em vez de instalar a instância manualmente e ajustar os parâmetros
posteriormente, as principais decisões de infraestrutura são registradas
previamente em um arquivo de configuração.

O resultado esperado é uma instalação com:

-   armazenamento planejado;
-   TempDB previamente dimensionada;
-   logs separados;
-   limite de memória definido;
-   paralelismo configurado;
-   contas de serviço padronizadas;
-   diretórios previamente definidos;
-   configuração de rede estabelecida;
-   possibilidade de execução via linha de comando.

Esse modelo aproxima o ambiente de laboratório/portfólio de uma
abordagem utilizada em ambientes administrados profissionalmente:
**configuração como código e padronização**.

