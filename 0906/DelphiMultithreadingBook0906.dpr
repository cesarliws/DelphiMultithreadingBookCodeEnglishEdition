program DelphiMultithreadingBook0906;

uses
  System.StartUpCopy,
  FMX.Forms,
  DelphiMultithreadingBook0906.MainForm in 'DelphiMultithreadingBook0906.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0906.ApiDownloader in 'DelphiMultithreadingBook0906.ApiDownloader.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
