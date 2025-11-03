program DelphiMultithreadingBook0803;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0803.MainForm in 'DelphiMultithreadingBook0803.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0803.SharedData in 'DelphiMultithreadingBook0803.SharedData.pas',
  DelphiMultithreadingBook0803.ConsumerThread in 'DelphiMultithreadingBook0803.ConsumerThread.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
