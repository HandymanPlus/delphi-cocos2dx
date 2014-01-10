(********************************************************************)
(* Tomes of Delphi: Algorithms and Data Structures                  *)
(* Source code copyright (c) Julian M Bucknall, 1999-2001           *)
(* All rights reserved                                              *)
(*------------------------------------------------------------------*)
unit tdHashBase;

interface

function getClosestPrime(const size: Cardinal): Cardinal;
function PJWHash(const key: string; tableSize: Cardinal): Cardinal;
function PJWHashEx(const key: string): Cardinal;

implementation

function getClosestPrime(const size: Cardinal): Cardinal;
{$INCLUDE tdPrimes.inc}
const
  Forever = true;
var
  L, R, M: integer;
  RootN: integer;
  IsPrime: boolean;
  DivisorIndex: integer;
begin
  {treat 2 as a special case}
  if (size = 2) then
  begin
    Result := size;
    Exit;
  end;
  {make the result equal to N, and if it's even, the next odd number}
  if Odd(size) then
    Result := size
  else
    Result := succ(size);
  {if the result is within our prime number table, use binary search
   to find the equal or next highest prime number}
  if (Result <= MaxPrime) then
  begin
    L := 0;
    R := pred(PrimeCount);
    while (L <= R) do
    begin
      M := (L + R) div 2;
      if (Result = Primes[M]) then
        Exit
      else if (Result < Primes[M]) then
        R := pred(M)
      else
        L := succ(M);
    end;
    Result := Primes[L];
    Exit;
  end;
  {the result is outside our prime number table range, use the
   standard method for testing primality (do any of the primes up to
   the root of the number divide it exactly?) and continue
   incrementing the result by 2 until it is prime}
  if (Result <= (MaxPrime * MaxPrime)) then
  begin
    while Forever do
    begin
      RootN := round(Sqrt(Result));
      DivisorIndex := 1; {ignore the prime number 2}
      IsPrime := true;
      while (DivisorIndex < PrimeCount) and (RootN > Primes[DivisorIndex]) do
      begin
        if ((Result div Primes[DivisorIndex]) * Primes[DivisorIndex] = Result)
          then
        begin
          IsPrime := false;
          Break;
        end;
        inc(DivisorIndex);
      end;
      if IsPrime then
        Exit;
      inc(Result, 2);
    end;
  end;

end;

function PJWHash(const key: string; tableSize: Cardinal): Cardinal;
var
  g: Cardinal;
  i: Integer;
  hash: Cardinal;
begin
  hash := 0;
  for i := 1 to Length(key) do
  begin
    hash := (hash shl 4) + Ord(key[i]);
    g := hash and $F0000000;
    if g <> 0 then
      hash := (hash xor (g shr 24)) xor g;
  end;
  Result := hash mod tableSize;
end;

function PJWHashEx(const key: string): Cardinal;
var
  g: Cardinal;
  i: Integer;
  hash: Cardinal;
begin
  hash := 0;
  for i := 1 to Length(key) do
  begin
    hash := (hash shl 4) + Ord(key[i]);
    g := hash and $F0000000;
    if g <> 0 then
      hash := (hash xor (g shr 24)) xor g;
  end;
  Result := hash;
end;

end.

