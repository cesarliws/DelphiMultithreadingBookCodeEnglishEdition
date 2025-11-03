program DelphiMultithreadingBook0904;

uses
  System.StartUpCopy,
  FMX.Forms,
  DelphiMultithreadingBook0904.MainForm in 'DelphiMultithreadingBook0904.MainForm.pas' {MainForm},
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
