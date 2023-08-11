/*
Cleaning Data using SQL Queries
*/

-- Raw data that we are going to use

select * 
from dbo.Nashville_Housing;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- standardise the Sale Date Format from Datetime to Date

select SaleDate,Convert(Date,SaleDate)
from Nasville_Housing.dbo.Nashville_Housing;

update Nashville_Housing
set SaleDate = CONVERT(Date,SaleDate);

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Populate property Address


select a.UniqueID, b.UniqueID, a.ParcelID, b.ParcelID,a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Nasville_Housing.dbo.Nashville_Housing as a
JOIN Nasville_Housing.dbo.Nashville_Housing as b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null or b.PropertyAddress is null;

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Nasville_Housing.dbo.Nashville_Housing as a
JOIN Nasville_Housing.dbo.Nashville_Housing as b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null or b.PropertyAddress is null;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Breaking out address into individual columns(Address,City, State)

--- Property Address to Address and City
select PropertyAddress
from Nasville_Housing.dbo.Nashville_Housing

select SUBSTRING(PropertyAddress, 1, (CHARINDEX(',',PropertyAddress)-1)) as Address,
SUBSTRING(PropertyAddress,(CHARINDEX(',',PropertyAddress)+1), LEN(PropertyAddress)) as City
from Nasville_Housing.dbo.Nashville_Housing

-- Create new column for Address and city

Alter table Nasville_Housing.dbo.Nashville_Housing
ADD PropertySplitAddress varchar(255);

Alter table Nasville_Housing.dbo.Nashville_Housing
ADD PropertySplitCity varchar(255);

--Update the values for address and city column

update Nasville_Housing.dbo.Nashville_Housing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, (CHARINDEX(',',PropertyAddress)-1));

update Nasville_Housing.dbo.Nashville_Housing
set PropertySplitCity = SUBSTRING(PropertyAddress,(CHARINDEX(',',PropertyAddress)+1), LEN(PropertyAddress));


-- Owner address to address, city and state

select OwnerAddress
from Nasville_Housing.dbo.Nashville_Housing

select 
PARSENAME(Replace(OwnerAddress,',','.'),3) as Address,
PARSENAME(Replace(OwnerAddress,',','.'),2) as City,
PARSENAME(Replace(OwnerAddress,',','.'),1) as State
from Nasville_Housing.dbo.Nashville_Housing

-- Create new column for Address, city and state

Alter table Nasville_Housing.dbo.Nashville_Housing
ADD OwnerSplitAddress varchar(255);

Alter table Nasville_Housing.dbo.Nashville_Housing
ADD OwnerSplitCity varchar(255);

Alter table Nasville_Housing.dbo.Nashville_Housing
ADD OwnerSplitState varchar(255);

--Update the values for address, city and state column

update Nasville_Housing.dbo.Nashville_Housing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3);

update Nasville_Housing.dbo.Nashville_Housing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2);

update Nasville_Housing.dbo.Nashville_Housing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1);


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Change 1 and 0 to Yes and No in "Sold as Vacant" field


Alter table Nasville_Housing.dbo.Nashville_Housing
add SoldAsVacantNew varchar(3)

update Nasville_Housing.dbo.Nashville_Housing
set SoldAsVacantNew = case when SoldAsVacant = 0 then 'No'
		 when SoldAsVacant = 1 then 'Yes'
		 end

Select distinct(SoldAsVacantNew), COUNT(SoldAsVacantNew)
from Nasville_Housing.dbo.Nashville_Housing
group by SoldAsVacantNew
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates


-- Create CTE
with RowNumCTE as(
select *, 
	Row_number() over(
	partition by parcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
				 UniqueID
) row_num
from Nasville_Housing.dbo.Nashville_Housing
)
-- delete duplicate rows
delete
from RowNumCTE
where row_num > 1

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Delete unused column

alter table Nasville_Housing.dbo.Nashville_Housing
drop column PropertyAddress, SoldAsVacant, OwnerAddress,TaxDistrict
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Data Exploration

-- Finding Average Value of House by Built Year

 select distinct(yearbuilt), avg(saleprice) as Average_Value
 from Nasville_Housing.dbo.Nashville_Housing
 group by YearBuilt
 order by YearBuilt
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Avergae value of a house based on number of bedrooms and bathrooms

select Bedrooms,FullBath,HalfBath, avg(saleprice) as average_value
from  Nasville_Housing.dbo.Nashville_Housing
group by Bedrooms,FullBath,HalfBath
order by Bedrooms,FullBath,HalfBath

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--See the effect total acreage has on house value
select Acreage, avg(Saleprice) as average_value
from  Nasville_Housing.dbo.Nashville_Housing
group by Acreage
order by Acreage
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Does the city a house is located have an effect on the total value of a house

select PropertySplitCity, AVG(saleprice)
from Nasville_Housing.dbo.Nashville_Housing
group by propertysplitcity
order by propertysplitcity

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Check which month sold the most amount of houses

-- Create and update the new column to extract the month

alter table  Nasville_Housing.dbo.Nashville_Housing
add   MonthSold varchar(20)

update Nasville_Housing.dbo.Nashville_Housing
-- set MonthOnly =PARSENAME(replace(saledate,'-','.'),2)
set MonthSold = datename(MONTH,SaleDate)


select monthsold, count(*) as TotalHouseSold
from Nasville_Housing.dbo.Nashville_Housing
group by monthsold
order by TotalHouseSold desc

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Total Value vs Sold value

select Saleprice,TotalValue,(SalePrice-TotalValue) as diff
from Nasville_Housing.dbo.Nashville_Housing
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--LandType vs Total Value

select LandUse, avg(saleprice) as average_value 
from Nasville_Housing.dbo.Nashville_Housing
group by Landuse
order by average_value desc
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------