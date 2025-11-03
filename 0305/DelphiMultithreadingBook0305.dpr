program DelphiMultithreadingBook0305;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0305.MainForm in 'DelphiMultithreadingBook0305.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0305.Shared in 'DelphiMultithreadingBook0305.Shared.pas',
  DelphiMultithreadingBook0305.ProducerThread in 'DelphiMultithreadingBook0305.ProducerThread.pas',
  DelphiMultithreadingBook0305.ConsumerThread in 'DelphiMultithreadingBook0305.ConsumerThread.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
