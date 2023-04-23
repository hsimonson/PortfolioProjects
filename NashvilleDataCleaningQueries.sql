-- Data Cleaning using SQL --
-- Written 4/21/2023 by Henry Simonson
-- Last updated 4/23/2023

USE [Portfolio Project]
GO

-- #1
-- Standardizing Date Format to yyyy-mm-dd

Select SaleDate, CONVERT(Date,SaleDate)
From [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateFormatted Date;

Update NashvilleHousing
Set SaleDateFormatted = CONVERT(Date,SaleDate)

Select SaleDateFormatted
From [Portfolio Project]..NashvilleHousing

-- #2
-- Inserting data into null address fields

Select PropertyAddress
From [Portfolio Project]..NashvilleHousing
Order by ParcelID

Select self1.PropertyAddress, self2.PropertyAddress, self1.ParcelID, self2.ParcelID, ISNULL(self1.PropertyAddress, self2.PropertyAddress)
From [Portfolio Project]..NashvilleHousing self1
JOIN [Portfolio Project]..NashvilleHousing self2
	on self1.ParcelID = self2.ParcelID
	AND self1.[UniqueID ] != self2.[UniqueID ]
Where Self1.PropertyAddress is null

Update self1
Set PropertyAddress = ISNULL(self1.PropertyAddress, self2.PropertyAddress)
From [Portfolio Project]..NashvilleHousing self1
JOIN [Portfolio Project]..NashvilleHousing self2
	on self1.ParcelID = self2.ParcelID
	AND self1.[UniqueID ] != self2.[UniqueID ]
Where Self1.PropertyAddress is null


-- #3
-- Seperating Addresses

-- Seperating Property Address into Street Address and City

Select PropertyAddress
From [Portfolio Project]..NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as City
From [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropAddress nvarchar(255);

Update NashvilleHousing
Set PropAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropCity nvarchar(255);

Update NashvilleHousing
Set PropCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

Select PropCity, PropAddress
From [Portfolio Project]..NashvilleHousing
Order by PropCity asc

-- Seperating Owner Address into Street Address, City, and State

Select
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerStreetAddress nvarchar(255);

Update NashvilleHousing
Set OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerCity nvarchar(255);

Update NashvilleHousing
Set OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerState nvarchar(255);

Update NashvilleHousing
Set OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

Select OwnerStreetAddress, OwnerCity, OwnerState
From [Portfolio Project]..NashvilleHousing

-- #4
-- Standardizing format of SoldAsVacant field to only contain 'No' or 'Yes'

Select SoldAsVacant,
Case 
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
END
From [Portfolio Project]..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case 
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
END

-- #5
-- Removing duplicates

WITH RowNumCTE AS (
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) row_num

From [Portfolio Project]..NashvilleHousing
)
delete
From RowNumCTE
Where row_num > 1

-- #6
-- Delete Unused Columns

Select *
From [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

