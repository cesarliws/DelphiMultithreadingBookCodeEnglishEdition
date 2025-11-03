unit DelphiMultithreadingBook0201.Snippets;

// Unit usada somente para criar os snippets de códigos aleatórios usados em
// trechos do livro. Não é código pronto para uso.

interface

uses
  System.Classes,
  Vcl.StdCtrls,
  Vcl.Forms;

type
  // Apenas modelo para estudos, não usada no Projeto.
  // Leia os comentários
  TWorkerThread = class(TThread)
  protected
    procedure Execute; override;
  public
    // Construtor para inicializar a thread
    constructor Create(CreateSuspended: Boolean); overload;
  end;

type
  TBusyWorkerThread = class(TThread)
  protected
    procedure Execute; override;
  end;

type
  TBackgroundWorkerThread = class(TThread)
  protected
    procedure Execute; override;
  end;

type
  TRunThreadForm = class(TForm)
    LogMemo: TMemo;
    StartButton: TButton;
    procedure StartButtonClick(Sender: TObject);
  private
    FWorkerThread: TWorkerThread;
  end;

type
  TTasksForm = class(TForm)
   StartButton: TButton;
   StopButton: TButton;
   procedure FormDestroy(Sender: TObject);
   procedure StartButtonClick(Sender: TObject);
   procedure StopButtonClick(Sender: TObject);
  private
    FWorkerThread: TWorkerThread;
  end;

implementation

var
  RunThreadForm: TRunThreadForm;

{ TRunThreadForm }

procedure TRunThreadForm.StartButtonClick(Sender: TObject);
begin
  // Cria a thread em estado suspenso
  FWorkerThread := TWorkerThread.Create(True);
  // Configurações adicionais podem ir aqui
  // ...
  // Inicia a execução da thread
  FWorkerThread.Start;
end;

{ TWorkerThread }

constructor TWorkerThread.Create(CreateSuspended: Boolean);
begin
  // Chame o construtor do ancestral TThread
  inherited Create(CreateSuspended);
  // (Opcional) Adicione suas próprias inicializações aqui
end;

procedure TWorkerThread.Execute;
begin
  // --- Este é o coração da sua thread! ---
  // Todo o código que você quer que execute em segundo plano vai aqui.
  // IMPORTANTE: NUNCA acesse componentes da interface de usuário (UI) aqui!
  // Isso será explicado em detalhes mais adiante.

  // (Este é um exemplo de CÓDIGO RUIM - apenas para ilustração do conceito)
  // LogMemo.Lines.Add('A thread está executando!');

  // Simula um trabalho demorado
  Sleep(5000); // Pausa a execução da thread por 5 segundos

  // (Este é um exemplo de CÓDIGO RUIM)
  // LogMemo.Lines.Add('A thread terminou!');

  // (Opcional) Verifique a propriedade Terminated periodicamente para permitir
  // o encerramento da thread
  // if not Terminated then
  // begin
  // // Continua o trabalho
  // end;
end;

{ TTasksForm }

procedure TTasksForm.FormDestroy(Sender: TObject);
begin
  // Garante que a thread seja terminada e liberada ao fechar o formulário
  if Assigned(FWorkerThread) then
  begin
    FWorkerThread.Terminate;
    FWorkerThread.WaitFor;
    FWorkerThread.Free;
    FWorkerThread := nil;
  end;
end;

procedure TTasksForm.StartButtonClick(Sender: TObject);
begin
  if not Assigned(FWorkerThread) then
  begin
    FWorkerThread := TWorkerThread.Create(True);
    FWorkerThread.FreeOnTerminate := False; // IMPORTANTE: Gerenciamento manual
    FWorkerThread.Start;
  end;
end;

procedure TTasksForm.StopButtonClick(Sender: TObject);
begin
  if Assigned(FWorkerThread) then
  begin
    FWorkerThread.Terminate; // Sinaliza para a thread terminar cooperativamente
    FWorkerThread.WaitFor;   // Espera a thread realmente terminar
    FWorkerThread.Free;      // Libera o objeto thread
    FWorkerThread := nil;    // Limpa a referência
  end;
end;

{ TBusyWorkerThread }

// Dentro do método Execute da TThread
procedure TBusyWorkerThread.Execute;
begin
  // ... trabalho demorado ...
  TThread.Synchronize(nil,
    procedure
    begin
      // Este código roda na thread principal (UI thread)
      RunThreadForm.LogMemo.Lines.Add('Trabalho concluído!');
    end);
end;

{ TBackgroundWorkerThread }

// Dentro do método Execute da TThread
procedure TBackgroundWorkerThread.Execute;
begin
  // ... trabalho demorado ...
  TThread.Queue(nil,
    procedure
    begin
      // Este código roda na thread principal (UI thread)
      RunThreadForm.LogMemo.Lines.Add('Trabalho concluído (assíncrono)!');
    end);
end;

end.
