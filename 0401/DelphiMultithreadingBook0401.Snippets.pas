unit DelphiMultithreadingBook0401.Snippets;

// Esta unit é apenas para criar os Snippets de código usados no livro

interface

implementation

{$WARNINGS OFF}

uses
  System.Classes, DelphiMultithreadingBook0401.SharedData;

type
  TMinhaThread = class(TThread)
  end;

  TSnippets = class
  public
    function CreateThreadAndRunNow: TMinhaThread;
    function CreateThreadSuspended: TMinhaThread;
  end;

  TMyLongTaskThread = class(TThread)
  end;

  TMainForm = class
    procedure PauseButton(Sender: TObject);
    procedure ResumeButton(Sender: TObject);
    procedure StartButton(Sender: TObject);
  private
     FWorkerThread: TMyLongTaskThread;
  end;

// ... na interface
type
  TPausableWorkerThread = class(TThread)
  //...
  protected
    // Adicionar
    procedure TerminatedSet; override;
  //...
  end;

{ TSnippets }

function TSnippets.CreateThreadAndRunNow: TMinhaThread;
var
  MinhaThread : TMinhaThread;
begin
  // A thread começa a executar o método Execute imediatamente
  MinhaThread := TMinhaThread.Create(False);
  Result := MinhaThread;
end;

function TSnippets.CreateThreadSuspended: TMinhaThread;
var
  MinhaThread : TMinhaThread;
begin
  // Thread é criada, mas não executa Execute ainda
  MinhaThread := TMinhaThread.Create(True);
  // ... Configurações da thread ...

  // Inicia a execução do método Execute
  MinhaThread.Start;
end;

// No Form principal
procedure TMainForm.StartButton(Sender: TObject);
begin
  FWorkerThread := TMyLongTaskThread.Create(False); // Inicia
end;

procedure TMainForm.PauseButton(Sender: TObject);
begin
  if Assigned(FWorkerThread) then
    // Pausa a thread (APENAS PARA DEPURAR/ILUSTRAR O CONCEITO)
    FWorkerThread.Suspend;
end;

procedure TMainForm.ResumeButton(Sender: TObject);
begin
  if Assigned(FWorkerThread) then
    // Retoma a thread (APENAS PARA DEPURAR/ILUSTRAR O CONCEITO)
    FWorkerThread.Resume;
end;

// ... na implementation
procedure TPausableWorkerThread.TerminatedSet;
begin
  inherited;
  // A própria thread se encarrega de sinalizar o evento para sair do
  // estado de espera e poder terminar sua execução.
  PauseEvent.SetEvent;
end;

end.
