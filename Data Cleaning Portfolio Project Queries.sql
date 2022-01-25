/*
Cleaning Data in SQL Queries
*/

select * from PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDateConverted, convert(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate=convert(Date, SaleDate)


-- If it doesn't Update properly

Alter table NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted=convert(Date, SaleDate)

--------------------------------------------------------------------------------------------------------------------------


-- Populate Property Address data
select *
from PortfolioProject.dbo.NashvilleHousing 
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing 

--select 
--SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
--,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
--from PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter table NashvilleHousing
Add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select * 
from PortfolioProject.dbo.NashvilleHousing


--select OwnerAddress 
--from PortfolioProject.dbo.NashvilleHousing

--select
--PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
--,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
--,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
--from PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress=PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity=PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter table NashvilleHousing
Add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState=PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

select * 
from PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(soldasvacant), count(soldasvacant)
from PortfolioProject.dbo.NashvilleHousing
group by soldasvacant
order by 2

select soldasvacant
, case when soldasvacant='Y' then 'Yes'
       when soldasvacant='N' then 'No'
	   else soldasvacant
	   end
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set soldasvacant=case when soldasvacant='Y' then 'Yes'
       when soldasvacant='N' then 'No'
	   else soldasvacant
	   end





--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE as(
select * ,
ROW_NUMBER() over (
Partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by
			    UniqueID
			 )row_num
from PortfolioProject.dbo.NashvilleHousing
)
delete
from RowNumCTE
where row_num >1





--------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select * 
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, PropertyAddress, TaxDistrict

alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate

