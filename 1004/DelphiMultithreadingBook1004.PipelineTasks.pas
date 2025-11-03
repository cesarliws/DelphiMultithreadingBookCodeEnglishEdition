unit DelphiMultithreadingBook1004.PipelineTasks;

interface

uses
  System.Classes, System.Threading, DelphiMultithreadingBook.CancellationToken;

type
  TPipelineTasks = class
  public
    class function LoadCustomersAsync(const Token: ICancellationToken): IFuture<TStrings>; static;
    class function LoadProductsAsync(const Token: ICancellationToken): IFuture<TStrings>; static;
    class function GenerateOrderReportAsync(const CustomerData, ProductData: TStrings;
      const Token: ICancellationToken): IFuture<string>; static;
  end;

implementation

uses
  System.SysUtils;

{ TPipelineTasks }

class function TPipelineTasks.LoadCustomersAsync(const Token: ICancellationToken):
  IFuture<TStrings>;
begin
  Result := TTask.Future<TStrings>(
    function: TStrings
    var
      Customers: TStringList;
      i: Integer;
    begin
      // Simulate work, checking the token periodically
      for i := 1 to 20 do
      begin
        // Throws an exception if cancelled
        Token.ThrowIfCancellationRequested;
        Sleep(100);
      end;
      Customers := TStringList.Create;
      Customers.Add('Customer: 1 - John Smith');
      Customers.Add('Customer: 2 - Mary Jones');
      Result := Customers;
    end);
end;

class function TPipelineTasks.LoadProductsAsync(const Token: ICancellationToken):
  IFuture<TStrings>;
begin
  Result := TTask.Future<TStrings>(
    function: TStrings
    var
      Products: TStringList;
      i: Integer;
    begin
      for i := 1 to 15 do
      begin
        Token.ThrowIfCancellationRequested;
        Sleep(100);
      end;
      Products := TStringList.Create;
      Products.Add('Product: 101 - Laptop');
      Products.Add('Product: 102 - Mouse');
      Result := Products;
    end);
end;

class function TPipelineTasks.GenerateOrderReportAsync(const CustomerData, ProductData: TStrings;
  const Token: ICancellationToken): IFuture<string>;
begin
  Result := TTask.Future<string>(
    function: string
    var
      i: Integer;
      Report: TStrings;
    begin
      for i := 1 to 10 do
      begin
        Token.ThrowIfCancellationRequested;
        Sleep(100);
      end;
      Report := TStringList.Create;
      try
        Report.Add(Format('Report Generated: %d customers and %d products.',
          [CustomerData.Count, ProductData.Count]));
        Report.Add('--- Customers ---');
        Report.AddStrings(CustomerData);
        Report.Add('--- Products ---');
        Report.AddStrings(ProductData);
        Report.Add('-----------------');
        Result :=  Report.Text;
      finally
        Report.Free;
      end;
    end);
end;

end.
