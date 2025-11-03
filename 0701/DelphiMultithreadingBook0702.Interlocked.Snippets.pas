unit DelphiMultithreadingBook0702.Interlocked.Snippets;

interface


implementation

uses
  System.SyncObjs;

// Exemplo: Contador thread-safe
var
  // Deve ser acessível por todas as threads
  GlobalCounter: Integer;

procedure ThreadSafeCounter;
begin
  // ...
  // Dentro de uma thread:
  // Seguro para múltiplas threads
  TInterlocked.Increment(GlobalCounter);
  // ...
end;

// Exemplo: Somar pontos thread-safe
var
  TotalScore: Integer;

procedure UpdateScoreCountBy10;
begin
  // ...
  // Dentro de uma thread:
  // Adiciona 10 pontos atomicamente
  TInterlocked.Add(TotalScore, 10);
  // ...
end;

// Exemplo: Troca atômica de um flag booleano
var
  IsBusy: Boolean;

procedure UpdateBusyState;
begin
  // ...
  // Para adquirir o "status de ocupado" atomicamente:
  if not TInterlocked.Exchange(IsBusy, True) then
  begin
    // Se retornou False (o valor original), então IsBusy era False e agora é True.
    // Significa que esta thread foi a primeira a definir para True.
    // Pode prosseguir com a tarefa.
  end
  else
  begin
    // Retornou True, então IsBusy já era True. Já está ocupado.
    // Não pode prosseguir.
  end;

  // ... Ao terminar a tarefa:
  // Libera o flag atomicamente
  TInterlocked.Exchange(IsBusy, False);
  // ...
end;


// Exemplo: Atualização de um valor apenas se ele não mudou
var
  CurrentValue: Integer;
  DesiredValue: Integer;
  OldValue: Integer;

procedure UpdateWithRetry;
begin
  // ...
  // Loop de "tentativa e erro" para atualização lock-free
  repeat
    OldValue := CurrentValue; // Lê o valor atual
    DesiredValue := OldValue + 10; // Calcula o novo valor
    // Tenta definir CurrentValue para DesiredValue SOMENTE se CurrentValue
    // ainda for OldValue
    // Retorna o valor de CurrentValue ANTES da tentativa de troca.
  until TInterlocked.CompareExchange(CurrentValue, DesiredValue, OldValue) = OldValue;
  // O loop continua até que a troca seja bem-sucedida (garantindo atomicidade)
  // ...
end;

end.
