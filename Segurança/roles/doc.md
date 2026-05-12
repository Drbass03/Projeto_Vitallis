# Script de criação de roles

Esta pasta contém os scripts relacionados à criação de usuários, roles e políticas de segurança aplicadas no ambiente de banco de dados

As roles definem quais objetos do banco de dados podem receber operações de leitura, escrita e execução, garantindo maior controle de acesso, segregação de responsabilidades e governança dos dados.

Também estão incluídas implementações de Row-Level Security (RLS), utilizadas para restringir o acesso aos dados de acordo com o usuário conectado. Nesse cenário, médicos e usuários possuem permissões e visões diferentes sobre as informações do sistema.

Os testes utilizando `EXECUTE AS USER` foram aplicados para simular diferentes contextos de acesso, permitindo validar na prática como as regras de segurança e as políticas de RLS se comportam para cada perfil de usuário.a
