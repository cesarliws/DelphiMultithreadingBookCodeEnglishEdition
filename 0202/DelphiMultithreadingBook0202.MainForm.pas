unit DelphiMultithreadingBook0202.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls;

type
  TMainForm = class(TForm)
    StartThreadQueueButton: TButton;
    StartThreadSynchronizeButton: TButton;
    LogMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartThreadQueueButtonClick(Sender: TObject);
    procedure StartThreadSynchronizeButtonClick(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

uses
  DelphiMultithreadingBook0202.QueueOrSynchronizeThread, DelphiMultithreadingBook.Utils;

{$R *.dfm}

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started, click the buttons to start the threads.');
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  UnregisterLogger;
end;

procedure TMainForm.StartThreadQueueButtonClick(Sender: TObject);
begin
  // We create an instance of our thread, passing the LogMemo and indicating to use Queue
  TQueueOrSynchronizeThread.Create(LogMemo, TInterfaceUpdateType.Queue);
end;

procedure TMainForm.StartThreadSynchronizeButtonClick(Sender: TObject);
begin
  // We create an instance of our thread, passing the LogMemo and indicating to use Synchronize
  TQueueOrSynchronizeThread.Create(LogMemo, TInterfaceUpdateType.Synchronize);
end;

end.
