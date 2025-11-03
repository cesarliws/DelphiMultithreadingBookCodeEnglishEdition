TThread.Synchronize - A Sincronização Direta

  // Dentro do método Execute da sua TThread personalizada:
  Synchronize(
    procedure
    begin
      // Código que precisa ser executado na thread principal (UI Thread)
      MainForm.LogMemo.Lines.Add('Mensagem da thread, via Synchronize.');
      // Acesso seguro ao componente visual
    end
  );

TThread.Queue - A Sincronização Assíncrona

  // Dentro do método Execute da sua TThread personalizada:
  Queue(
    procedure
    begin
      // Código que precisa ser executado na thread principal (UI Thread)
      MainForm.LogMemo.Lines.Add('Mensagem da thread, via Queue.');
      // Acesso seguro ao componente visual
    end
  );

CheckSynchronize

  // Exemplo de uso de CheckSynchronize para manter a UI responsiva
  // (A ser usado na thread principal, em um loop de espera controlado)
  // Assumindo que 'ATasks' é um array de ITask a ser aguardado
  while not TTask.WaitForAll(ATasks, 1000) do // Espera 1 segundo ou até todas as tasks concluírem
  begin
    // Processa quaisquer requisições pendentes de TThread.Synchronize() e TThread.Queue()
    CheckSynchronize(0); // Passar 0 significa processar e retornar imediatamente

    // Opcional: Processar outras mensagens ou fazer outras atualizações rápidas
    // Application.MainForm.Update; // Processa requisições de pintura pendentes
  end;
  // Opcional: Tratar o resultado de TTask.WaitForAll

