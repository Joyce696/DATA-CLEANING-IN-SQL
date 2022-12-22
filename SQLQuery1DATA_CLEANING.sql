create database PORTFOLIO_PROJECT
USE PORTFOLIO_PROJECT
SELECT * FROM dbo.NASHVILLE_HOUSING
drop database PORTFOLIO_PROJECT

--CLEANING DATA USING SQL--

SELECT * from 
PORTFOLIO_PROJECT.dbo.NASHVILLE_HOUSING

---CHANGING THE SALEDATE COLUMN FORMAT

SELECT SaleDate, CONVERT(DATE,Saledate)
from PORTFOLIO_PROJECT.dbo.NASHVILLE_HOUSING

UPDATE NASHVILLE_HOUSING
SET SaleDate = CONVERT(DATE,Saledate)

--I used alter to do thesame thing because the changes made by the update did not reflect 
--so i created a new date column and populated it, also deleted the previous column---

ALTER TABLE NASHVILLE_HOUSING
ADD SaleDate2 date;

UPDATE NASHVILLE_HOUSING
SET SaleDate2 = CONVERT(DATE,Saledate)

Alter Table NASHVILLE_HOUSING
drop column saledate

---POPULATE PROPERTY ADDRESS DATA,
--remove null rows using join and functions.

SELECT * 
from PORTFOLIO_PROJECT.dbo.NASHVILLE_HOUSING
where PropertyAddress is NULL

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
from PORTFOLIO_PROJECT.dbo.NASHVILLE_HOUSING as A
JOIN PORTFOLIO_PROJECT.dbo.NASHVILLE_HOUSING as B
   ON A.ParcelID=B.ParcelID
   AND A.[UniqueID ]!= B.[UniqueID ]
   WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
from PORTFOLIO_PROJECT.dbo.NASHVILLE_HOUSING as A
JOIN PORTFOLIO_PROJECT.dbo.NASHVILLE_HOUSING as B
   ON A.ParcelID=B.ParcelID
   AND A.[UniqueID ]!= B.[UniqueID ]
   WHERE A.PropertyAddress IS NULL

--- breaking addresses into fragments.

SELECT PropertyAddress 
from PORTFOLIO_PROJECT.dbo.NASHVILLE_HOUSING
--where PropertyAddress is NULL

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress)) as Address
from PORTFOLIO_PROJECT.dbo.NASHVILLE_HOUSING

Alter Table NASHVILLE_HOUSING
add PropertySplitAddress NVarchar(255)

UPDATE NASHVILLE_HOUSING 
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

Alter Table NASHVILLE_HOUSING
add PropertySplitCity NVarchar(255)

UPDATE NASHVILLE_HOUSING
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress)) 

select OwnerAddress
from PORTFOLIO_PROJECT.dbo.NASHVILLE_HOUSING

---Easy way of Seperating Items in a Column
select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OwnerAddress_Number,
PARSENAME(REPLACE(Owneraddress, ',', '.'), 2)as OwnerAddress_Location,
PARSENAME(REPLACE(Owneraddress, ',', '.'), 1)as OwnerAddress_State
from PORTFOLIO_PROJECT.dbo.NASHVILLE_HOUSING

Alter table dbo.NASHVILLE_HOUSING add OwnerAddress_Number Nvarchar(233), OwnerAddress_Location Nvarchar(233),
OwnerAddress_State Nvarchar(233)

UPDATE dbo.NASHVILLE_HOUSING
SET OwnerAddress_Number = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), 
OwnerAddress_Location = PARSENAME(REPLACE(Owneraddress, ',', '.'), 2),
OwnerAddress_State = PARSENAME(REPLACE(Owneraddress, ',', '.'), 1)

--Changing the complete words THAT is Y AS YES AND N AS NO

SELECT DISTINCT(SoldAsVacant), COUNT(Soldasvacant)
FROM PORTFOLIO_PROJECT.dbo.NASHVILLE_HOUSING
group by SoldAsVacant
order by 2

UPDATE 
dbo.NASHVILLE_HOUSING
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
     WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 end

---REMOVING DUPLICATES

with RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate2,
				 LegalReference
				 ORDER BY UniqueID
				 ) ROW_NUM
FROM dbo.NASHVILLE_HOUSING
--order by ParcelID
)
delete FROM RowNumCTE
WHERE Row_Num > 1
--ORDER BY PropertyAddress

---DELETE UNUSED COLUMNS

ALTER TABLE dbo.NASHVILLE_HOUSING DROP column PropertyAddress, owneraddress
select * from dbo.NASHVILLE_HOUSING  