unit Unit4;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dbf, db, FileUtil, Forms, Controls, Graphics, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls, DBGrids, DbCtrls, unit6;

type

  { TForm4 }

  TForm4 = class(TForm)
    Button1: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button7: TButton;
    Button9: TButton;
    Datasource1: TDatasource;
    Dbf1: TDbf;
    Dbf2: TDbf;
    DBGrid1: TDBGrid;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    StaticText1: TStaticText;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Dbf1FilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure Edit1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    default_id_operat : integer;
    default_nm_operat : string;
    acrobat_path      : string;
  end;

var
  Form4: TForm4;

implementation
uses
   unit5;
{$R *.lfm}

{ TForm4 }

procedure TForm4.Button12Click(Sender: TObject);
begin
  OpenDialog1.DefaultExt:='*.exe';
  if OpenDialog1.Execute then
  begin
    Panel2.Caption    :=OpenDialog1.FileName;
    form4.acrobat_path:=OpenDialog1.FileName;
  end;
end;

// ustawienie opratora domyslnego
procedure TForm4.Button13Click(Sender: TObject);
begin
  default_id_operat :=dbf2.FieldByName('id').AsInteger;
  default_nm_operat :=dbf2.FieldByName('name').AsString;
  form4.Caption:='WanKom 0.1 ('+IntToStr(form4.default_id_operat)+') '+form4.default_nm_operat;
end;

procedure TForm4.Button11Click(Sender: TObject);
begin
  Close;
end;

procedure TForm4.Button10Click(Sender: TObject);
begin

end;

//operator dodaj
procedure TForm4.Button1Click(Sender: TObject);
var
  buf : string;
begin
  buf:='';
  if InputQuery('Identyfikator operatora', 'Prosze podac nazwe', false, buf) then
  begin
    dbf2.Insert;
    dbf2.FieldByName('name').AsString:=buf;
    dbf2.Post;

  end;
end;

// operator edytuj
procedure TForm4.Button2Click(Sender: TObject);
var
  buf : string;
begin
  dbf2.Edit;
  buf:=dbf2.FieldByName('name').AsString;
  if InputQuery('Identyfikator operatora', 'Prosze podac nazwe', false, buf) then
  begin
    dbf2.FieldByName('name').AsString:=buf;
    dbf2.Post;
  end
  else
    dbf2.Cancel;
end;

//operator usun
procedure TForm4.Button3Click(Sender: TObject);
begin
  if MessageDlg ('Pytanie', 'Czy napewno chcesz skasować ?', mtConfirmation, [mbYes, mbNo],0) = mrYes
  then
    begin
      dbf2.Delete;
    end;
end;
// import kontaktów
procedure TForm4.Button4Click(Sender: TObject);
var
  wagi : array[1..23] of byte; // tutaj bede trzymal pozycje pol i ich odpoowiedniki
  wgidx: byte;
  f    : TextFile;
  buf  : string;
  buf2 : string;
  idx  : byte;

  email1,email2,buf3 : string;
  dodanych           : integer;

  function FindWaga(txt : string):byte;
  var
    i : byte;
  begin
    FindWaga:=0; // jesli zero to blad - pole nie odnalezione
    i:=1;
    while (i < 24) and (UpperCase(ListaPol[i,1]) <> UpperCase(txt)) do inc(i);
    if i = 24 then exit; // blad pole nie odnalezione
    FindWaga:=i; // przypisanie indeksu znalezionego pola
  end;

begin
  if not (MessageDlg ('Pytanie', 'Import kontaktów dla operatora ['+dbf2.FieldByName('name').AsString+'] ?', mtConfirmation, [mbYes, mbNo],0) = mrYes)
  Then
    exit;

  form5.Memo1.Lines.Clear; // czyszczenie logu dla odrzuconych adresów

  OpenDialog1.DefaultExt:='*.csv';
  if not OpenDialog1.Execute then exit;

  AssignFile(f,OpenDialog1.FileName);
  {$I-}
  reset(f);
  if IOResult <> 0 then
  begin
    ShowMessage('Problem z otwarciem pliku');
    exit;
  end;

  // --------------------------------- odczyt naglowka
  readln(f,buf);
  wgidx:=0;
  while pos(',',buf) <> 0 do
  begin
    buf2:=copy(buf,1,pos(',',buf)-1);
    idx:=FindWaga(buf2);
    inc(wgidx);
    wagi[wgidx]:=idx;
    delete(buf,1,pos(',',buf));
  end;
  if buf <> '' then // ostatie pole - tu nie ma na koncu przecinka
  begin
    idx:=FindWaga(buf2);
    inc(wgidx);
    wagi[wgidx]:=idx;
  end;

  buf:=ExtractFilePath(paramstr(0));
  if buf[length(buf)] <> '\' then buf:=buf+'\';

  if dbf1.Active then dbf1.Close;
  dbf1.FilePathFull:=buf;
  dbf1.TableName:='kontakty.dbf';
  dbf1.TableLevel:=7;
  dbf1.Open;

  dodanych:=0;

  while not eof(f) do
  begin
    // --------------------------------- odczyt tresci ksiazki
    readln(f,buf);

    // sprawdzam czy taki email juz istnieje, jesli tak to nie dodaje
    wgidx:=0;
    buf3:=buf;
    email1:='';
    email2:='';
    while pos(',',buf3) <> 0 do
    begin
      buf2:=copy(buf3,1,pos(',',buf3)-1);
      inc(wgidx);
      case wagi[wgidx] of
         4 : email1:=buf2;
        15 : email2:=buf2;
      end;
      delete(buf3,1,pos(',',buf3));
    end;
    if buf3 <> '' then // ostatie pole - tu nie ma na koncu przecinka
    begin
      inc(wgidx);
      wagi[wgidx]:=idx;
      case wagi[wgidx] of
         4 : email1:=buf3;
        15 : email2:=buf3;
      end;
    end;

    if ((trim(email1) <> '') and not (dbf1.Locate(ListaPol[ 4,2],email1,[loCaseInsensitive, loPartialKey]) or dbf1.Locate(ListaPol[15,2],email1,[loCaseInsensitive, loPartialKey]))) or
       ((trim(email2) <> '') and not (dbf1.Locate(ListaPol[ 4,2],email2,[loCaseInsensitive, loPartialKey]) or dbf1.Locate(ListaPol[15,2],email2,[loCaseInsensitive, loPartialKey])))
    then
    begin
      dbf1.Insert;
      wgidx:=0;
      while pos(',',buf) <> 0 do
      begin
        buf2:=copy(buf,1,pos(',',buf)-1);
        inc(wgidx);

        if wagi[wgidx] <> 0 then dbf1.FieldByName(ListaPol[wagi[wgidx],2]).AsString:=buf2;
        delete(buf,1,pos(',',buf));
      end;
      if buf <> '' then // ostatie pole - tu nie ma na koncu przecinka
      begin
        inc(wgidx);
        wagi[wgidx]:=idx;
        if wagi[wgidx] <> 0 then dbf1.FieldByName(ListaPol[wagi[wgidx],2]).AsString:=buf2;
      end;

      dbf1.FieldByName('nmOperat').AsString :=dbf2.FieldByName('name').AsString;
      dbf1.FieldByName('idOperat').AsInteger:=dbf2.FieldByName('id').AsInteger;
      dbf1.Post;
      inc(dodanych);
    end
    else
      begin
        form5.Memo1.Lines.Add('Odrzucony: '+email1+' , '+email2);
      end;
  end;
  CloseFile(f);
  {$I+}
  form5.Memo1.Lines.Add('Dodanych: '+IntToStr(dodanych));
  form5.ShowModal;
end;

procedure TForm4.Button6Click(Sender: TObject);
begin

end;

procedure TForm4.Button7Click(Sender: TObject);
var
  buf : string;
  idx : byte;
begin
  if MessageDlg ('Pytanie', 'Czy napewno chcesz to zrobić? Operacja spowoduje wymazanie dotychczasowych danych !!!', mtConfirmation, [mbYes, mbNo],0) = mrNo
  then
    exit;
  if dbf1.Active then dbf1.Close;
  if dbf1.Active then dbf1.Close;

  buf:=ExtractFilePath(paramstr(0));
  if buf[length(buf)] <> '\' then buf:=buf+'\';

  Dbf1.FilePathFull := buf;
  Dbf1.TableLevel := 7; //Visual dBase VII
  Dbf1.TableName  := 'kontakty.dbf';

  Dbf1.FieldDefs.Add('id', ftAutoInc, 0, True);
  Dbf1.FieldDefs.Add('idOperat',   ftInteger, 0, True);
  Dbf1.FieldDefs.Add('nmOperat',   ftString, 80, True);

  With Dbf1.FieldDefs do
  begin
    for idx:=1 to 24 do Dbf1.FieldDefs.Add(ListaPol[idx,2], ftString, 80, True);
  End;
  Dbf1.CreateTable;

end;

procedure TForm4.Button8Click(Sender: TObject);
begin

end;

// tworzenie tabeli operatorów
procedure TForm4.Button9Click(Sender: TObject);
var
  buf : string;
begin
  if MessageDlg ('Pytanie', 'Czy napewno chcesz to zrobić? Operacja spowoduje wymazanie dotychczasowych danych !!!', mtConfirmation, [mbYes, mbNo],0) = mrNo
  then
    exit;

  if dbf1.Active then dbf1.Close;

  buf:=ExtractFilePath(paramstr(0));
  if buf[length(buf)] <> '\' then buf:=buf+'\';

  Dbf1.FilePathFull := buf;
  Dbf1.TableLevel := 7; //Visual dBase VII
  Dbf1.TableName  := 'operator.dbf'; // note: is the .dbf really required?
  With Dbf1.FieldDefs do
  begin
    Add('Id', ftAutoInc, 0, True); //Autoincrement field called Id
    Add('Name', ftString, 80, True); //80 character string field called Name
  End;
  Dbf1.CreateTable;
end;

// ustawienie filtru na operatora na potrzebe importu kontaktow.
// co prawda email nie moze sie powtarzac w obrembie opratora
// ale we wszystkich kontaktach moze wystepowac wielokrotnie
procedure TForm4.Dbf1FilterRecord(DataSet: TDataSet; var Accept: Boolean);
begin
  accept:=DataSet.FieldByName('idOperat').AsInteger = form4.default_id_operat;
end;

procedure TForm4.Edit1Change(Sender: TObject);
begin

end;

procedure TForm4.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if dbf2.Active then dbf2.Close;
  if dbf1.Active then dbf1.Close;
  CloseAction:=caHide;
end;

procedure TForm4.FormCreate(Sender: TObject);
begin
  form4.default_id_operat:=-1;
end;

procedure TForm4.FormShow(Sender: TObject);
var
  buf : string;
begin
  form4.Caption:='WanKom 0.1 ('+IntToStr(form4.default_id_operat)+') '+form4.default_nm_operat;

  buf:=ExtractFilePath(paramstr(0));
  if not FileExists(buf+'operator.dbf') then
  begin
    dbgrid1.Enabled:=false;
    button1.Enabled:=false;
    button2.Enabled:=false;
    button3.Enabled:=false;
  end
  else
  begin
    dbgrid1.Enabled:=true;
    button1.Enabled:=true;
    button2.Enabled:=true;
    button3.Enabled:=true;

    dbf2.Exclusive:=false;
    dbf2.FilePathFull:=buf;
    dbf2.TableName:='operator.dbf';

    try
      dbf2.Open;
    except on e:Exception do
      ShowMessage('Blad: '+e.Message);
    end;
  end;


end;

end.

