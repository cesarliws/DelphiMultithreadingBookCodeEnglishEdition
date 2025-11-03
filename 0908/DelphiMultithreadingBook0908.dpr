program DelphiMultithreadingBook0908;

uses
  System.StartUpCopy,
  FMX.Forms,
{$IF defined(MSWINDOWS)}
  WinApi.Windows,
{$ENDIF}
  DelphiMultithreadingBook0908.MainForm in 'DelphiMultithreadingBook0908.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0908.ImageProcessor in 'DelphiMultithreadingBook0908.ImageProcessor.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas',
  DelphiMultithreadingBook.CancellationToken in '..\Common\DelphiMultithreadingBook.CancellationToken.pas';

{$R *.res}

{$IF defined(MSWINDOWS)}
  // Necessário para processamento de imagens em Windows 32-bit
  // Sem isso, há o risco do erro "Out Of Memory" para imagens de fotos
  {$SetPEFlags IMAGE_FILE_LARGE_ADDRESS_AWARE}
{$ENDIF}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
