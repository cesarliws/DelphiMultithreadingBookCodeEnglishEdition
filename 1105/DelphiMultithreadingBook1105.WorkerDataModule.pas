unit DelphiMultithreadingBook1105.WorkerDataModule;

interface

uses
  FireDAC.Comp.Client, FireDAC.Phys.SQLite, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Stan.Param,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.SQLiteWrapper.Stat, Data.DB,
  FireDAC.Stan.ExprFuncs, FireDAC.ConsoleUI.Wait, FireDAC.Phys.SQLiteDef, System.SysUtils,
  System.Classes, DelphiMultithreadingBook1105.Interfaces, DelphiMultithreadingBook1105.Entities;

type
  TWorkerDM = class(TDataModule, IUnitOfWork)
    FDConnection: TFDConnection;
    FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink;
    procedure DataModuleDestroy(Sender: TObject);
  private
    function CreateQuery: TFDQuery;
  public
    // IUnitOfWork
    function GetCustomers: TCustomerList;
    function GetOrdersForCustomer(const CustomerId: string): TOrderList;
    function GetAllOrders: TOrderList;
    procedure SaveCustomer(const Customer: TCustomer);
    procedure DeleteCustomer(const CustomerId: string);
    procedure SaveOrder(const Order: TOrder);
    procedure UpdateOrder(const Order: TOrder);
    procedure DeleteOrder(const OrderID: Integer);
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}
{$R *.dfm}

{ TWorkerDM }

function TWorkerDM.CreateQuery: TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FDConnection;
  // Configure query for better performance
  Result.FetchOptions.CursorKind := ckForwardOnly;
  Result.FetchOptions.Mode := fmAll;
  Result.FetchOptions.RecsMax := -1;
  Result.FetchOptions.RowsetSize := -1;
  Result.FetchOptions.Unidirectional := True;
end;

procedure TWorkerDM.DataModuleDestroy(Sender: TObject);
begin
  FDConnection.Connected := False;
  inherited;
end;

function TWorkerDM.GetCustomers: TCustomerList;
var
  Customer: TCustomer;
  Query: TFDQuery;
begin
  Result := TCustomerList.Create(True);
  Query := CreateQuery;
  try
    Query.SQL.Text := 'SELECT * FROM Customers';
    Query.Open;
    while not Query.Eof do
    begin
      Customer := TCustomer.Create;
      Customer.CustomerID := Query.FieldByName('CustomerID').AsString;
      Customer.CompanyName := Query.FieldByName('CompanyName').AsString;
      Customer.ContactName := Query.FieldByName('ContactName').AsString;
      Customer.ContactTitle := Query.FieldByName('ContactTitle').AsString;
      Customer.Address := Query.FieldByName('Address').AsString;
      Customer.City := Query.FieldByName('City').AsString;
      Customer.Region := Query.FieldByName('Region').AsString;
      Customer.PostalCode := Query.FieldByName('PostalCode').AsString;
      Customer.Country := Query.FieldByName('Country').AsString;
      Customer.Phone := Query.FieldByName('Phone').AsString;
      Customer.Fax := Query.FieldByName('Fax').AsString;
      Result.Add(Customer);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TWorkerDM.GetOrdersForCustomer(const CustomerId: string): TOrderList;
var
  Query: TFDQuery;
  Order: TOrder;
begin
  Result := TOrderList.Create(True);
  Query := CreateQuery;
  try
    Query.SQL.Text := 'SELECT * FROM Orders WHERE CustomerID = :CustomerID';
    Query.ParamByName('CustomerID').AsString := CustomerId;
    Query.Open;
    while not Query.Eof do
    begin
      Order := TOrder.Create;
      Order.OrderID := Query.FieldByName('OrderID').AsInteger;
      Order.CustomerID := Query.FieldByName('CustomerID').AsString;
      Order.EmployeeID := Query.FieldByName('EmployeeID').AsInteger;
      Order.OrderDate := Query.FieldByName('OrderDate').AsDateTime;
      Order.RequiredDate := Query.FieldByName('RequiredDate').AsDateTime;
      Order.ShippedDate := Query.FieldByName('ShippedDate').AsDateTime;
      Order.ShipVia := Query.FieldByName('ShipVia').AsInteger;
      Order.Freight := Query.FieldByName('Freight').AsCurrency;
      Order.ShipName := Query.FieldByName('ShipName').AsString;
      Order.ShipAddress := Query.FieldByName('ShipAddress').AsString;
      Order.ShipCity := Query.FieldByName('ShipCity').AsString;
      Order.ShipRegion := Query.FieldByName('ShipRegion').AsString;
      Order.ShipPostalCode := Query.FieldByName('ShipPostalCode').AsString;
      Order.ShipCountry := Query.FieldByName('ShipCountry').AsString;

      Result.Add(Order);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TWorkerDM.GetAllOrders: TOrderList;
var
  Query: TFDQuery;
  Order: TOrder;
begin
  Result := TOrderList.Create(True);
  Query := CreateQuery;
  try
    Query.SQL.Text := 'SELECT * FROM Orders';
    Query.Open;
    while not Query.Eof do
    begin
      Order := TOrder.Create;
      Order.OrderID := Query.FieldByName('OrderID').AsInteger;
      Order.CustomerID := Query.FieldByName('CustomerID').AsString;
      Order.EmployeeID := Query.FieldByName('EmployeeID').AsInteger;
      Order.OrderDate := Query.FieldByName('OrderDate').AsDateTime;
      Order.RequiredDate := Query.FieldByName('RequiredDate').AsDateTime;
      Order.ShippedDate := Query.FieldByName('ShippedDate').AsDateTime;
      Order.ShipVia := Query.FieldByName('ShipVia').AsInteger;
      Order.Freight := Query.FieldByName('Freight').AsCurrency;
      Order.ShipName := Query.FieldByName('ShipName').AsString;
      Order.ShipAddress := Query.FieldByName('ShipAddress').AsString;
      Order.ShipCity := Query.FieldByName('ShipCity').AsString;
      Order.ShipRegion := Query.FieldByName('ShipRegion').AsString;
      Order.ShipPostalCode := Query.FieldByName('ShipPostalCode').AsString;
      Order.ShipCountry := Query.FieldByName('ShipCountry').AsString;
      Result.Add(Order);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

procedure TWorkerDM.SaveCustomer(const Customer: TCustomer);
var
  Query: TFDQuery;
begin
  Query := CreateQuery;
  try
    // Check if the customer already exists
    Query.SQL.Text := 'SELECT COUNT(*) FROM Customers WHERE CustomerID = :CustomerID';
    Query.ParamByName('CustomerID').AsString := Customer.CustomerID;
    Query.Open;
    if Query.Fields[0].AsInteger = 0 then
    begin
      // INSERT
      Query.SQL.Text := 'INSERT INTO Customers (CustomerID, CompanyName, ContactName, ' +
        'ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax) ' +
        'VALUES (:CustomerID, :CompanyName, :ContactName, :ContactTitle, ' +
        ':Address, :City, :Region, :PostalCode, :Country, :Phone, :Fax)';
    end
    else
    begin
      // UPDATE
      Query.SQL.Text := 'UPDATE Customers SET CompanyName = :CompanyName, ' +
        'ContactName = :ContactName, ContactTitle = :ContactTitle, ' +
        'Address = :Address, City = :City, Region = :Region, ' +
        'PostalCode = :PostalCode, Country = :Country, Phone = :Phone, ' +
        'Fax = :Fax WHERE CustomerID = :CustomerID';
    end;
    Query.ParamByName('CustomerID').AsString := Customer.CustomerID;
    Query.ParamByName('CompanyName').AsString := Customer.CompanyName;
    Query.ParamByName('ContactName').AsString := Customer.ContactName;
    Query.ParamByName('ContactTitle').AsString := Customer.ContactTitle;
    Query.ParamByName('Address').AsString := Customer.Address;
    Query.ParamByName('City').AsString := Customer.City;
    Query.ParamByName('Region').AsString := Customer.Region;
    Query.ParamByName('PostalCode').AsString := Customer.PostalCode;
    Query.ParamByName('Country').AsString := Customer.Country;
    Query.ParamByName('Phone').AsString := Customer.Phone;
    Query.ParamByName('Fax').AsString := Customer.Fax;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure TWorkerDM.DeleteCustomer(const CustomerId: string);
var
  Query: TFDQuery;
begin
  Query := CreateQuery;
  try
    // First, delete the orders (if there are constraints)
    Query.SQL.Text := 'DELETE FROM Orders WHERE CustomerID = :CustomerID';
    Query.ParamByName('CustomerID').AsString := CustomerId;
    Query.ExecSQL;
    // Then, delete the customer
    Query.SQL.Text := 'DELETE FROM Customers WHERE CustomerID = :CustomerID';
    Query.ParamByName('CustomerID').AsString := CustomerId;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure TWorkerDM.SaveOrder(const Order: TOrder);
var
  Query: TFDQuery;
begin
  Query := CreateQuery;
  try
    Query.SQL.Text := 'INSERT INTO Orders (CustomerID, EmployeeID, OrderDate, RequiredDate, ' +
      'ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ' +
      'ShipRegion, ShipPostalCode, ShipCountry) ' +
      'VALUES (:CustomerID, :EmployeeID, :OrderDate, :RequiredDate, ' +
      ':ShippedDate, :ShipVia, :Freight, :ShipName, :ShipAddress, :ShipCity, ' +
      ':ShipRegion, :ShipPostalCode, :ShipCountry)';
    Query.ParamByName('CustomerID').AsString := Order.CustomerID;
    Query.ParamByName('EmployeeID').AsInteger := Order.EmployeeID;
    Query.ParamByName('OrderDate').AsDateTime := Order.OrderDate;
    Query.ParamByName('RequiredDate').AsDateTime := Order.RequiredDate;
    Query.ParamByName('ShippedDate').AsDateTime := Order.ShippedDate;
    Query.ParamByName('ShipVia').AsInteger := Order.ShipVia;
    Query.ParamByName('Freight').AsCurrency := Order.Freight;
    Query.ParamByName('ShipName').AsString := Order.ShipName;
    Query.ParamByName('ShipAddress').AsString := Order.ShipAddress;
    Query.ParamByName('ShipCity').AsString := Order.ShipCity;
    Query.ParamByName('ShipRegion').AsString := Order.ShipRegion;
    Query.ParamByName('ShipPostalCode').AsString := Order.ShipPostalCode;
    Query.ParamByName('ShipCountry').AsString := Order.ShipCountry;
    Query.ExecSQL;
    // Retrieve the generated OrderID
    Query.SQL.Text := 'SELECT last_insert_rowid()';
    Query.Open;
    Order.OrderID := Query.Fields[0].AsInteger;
  finally
    Query.Free;
  end;
end;

procedure TWorkerDM.UpdateOrder(const Order: TOrder);
var
  Query: TFDQuery;
begin
  Query := CreateQuery;
  try
    Query.SQL.Text := 'UPDATE Orders SET CustomerID = :CustomerID, EmployeeID = :EmployeeID, ' +
      'OrderDate = :OrderDate, RequiredDate = :RequiredDate, ' +
      'ShippedDate = :ShippedDate, ShipVia = :ShipVia, Freight = :Freight, ' +
      'ShipName = :ShipName, ShipAddress = :ShipAddress, ShipCity = :ShipCity, ' +
      'ShipRegion = :ShipRegion, ShipPostalCode = :ShipPostalCode, ' +
      'ShipCountry = :ShipCountry WHERE OrderID = :OrderID';
    Query.ParamByName('OrderID').AsInteger := Order.OrderID;
    Query.ParamByName('CustomerID').AsString := Order.CustomerID;
    Query.ParamByName('EmployeeID').AsInteger := Order.EmployeeID;
    Query.ParamByName('OrderDate').AsDateTime := Order.OrderDate;
    Query.ParamByName('RequiredDate').AsDateTime := Order.RequiredDate;
    Query.ParamByName('ShippedDate').AsDateTime := Order.ShippedDate;
    Query.ParamByName('ShipVia').AsInteger := Order.ShipVia;
    Query.ParamByName('Freight').AsCurrency := Order.Freight;
    Query.ParamByName('ShipName').AsString := Order.ShipName;
    Query.ParamByName('ShipAddress').AsString := Order.ShipAddress;
    Query.ParamByName('ShipCity').AsString := Order.ShipCity;
    Query.ParamByName('ShipRegion').AsString := Order.ShipRegion;
    Query.ParamByName('ShipPostalCode').AsString := Order.ShipPostalCode;
    Query.ParamByName('ShipCountry').AsString := Order.ShipCountry;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure TWorkerDM.DeleteOrder(const OrderID: Integer);
var
  Query: TFDQuery;
begin
  Query := CreateQuery;
  try
    Query.SQL.Text := 'DELETE FROM Orders WHERE OrderID = :OrderID';
    Query.ParamByName('OrderID').AsInteger := OrderID;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

end.
