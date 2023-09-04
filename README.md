# getnet_pos_helper

A new Flutter plugin project.

## Setup

### Como fazer funcionar o deeplink do pagamento

Esse projeto não funcionou muito bem o retorno do deeplink do pagamento, tentei 3 semanas fazer funcionar utilizando uma lib
e simplesmente desisti!

Para funcionar fiz uma alteração no projeto que vai ser utilizado, nesse exemplo Sagres Mobile, MainActivity.kt

Lá coloquei o codigo que recebe o retorno do deep link e fucnionou, lembrando que tem que que ser no method channel que está lá também, se não, não vai funcionar!