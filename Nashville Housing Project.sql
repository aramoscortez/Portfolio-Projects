/*

Nashville Housing Data Cleaning

Skills Used:
	- CTE'S
	- ALTERING & UPDATING TABLES
	- CASE Statement
	- Joining Tables

*/



Select *
From Portfolio.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------

-- Standardizing Date Format

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)



-- If it doesn't update properly

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;



UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


-- Comparing the two

SELECT SaleDateConverted, CONVERT(Date, SaleDate) AS UsingConvertFunction
FROM Portfolio.dbo.NashvilleHousing


----------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM Portfolio.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio.dbo.NashvilleHousing AS a
JOIN Portfolio.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio.dbo.NashvilleHousing AS a
JOIN Portfolio.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL





----------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns



SELECT PropertyAddress
FROM Portfolio.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID



SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM Portfolio.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)




ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))




SELECT *
FROM Portfolio.dbo.NashvilleHousing

--------------------------------

-- An alternative way


SELECT OwnerAddress
FROM Portfolio.dbo.NashvilleHousing


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Portfolio.dbo.NashvilleHousing




ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)




ALTER TABLE NashvilleHousing 
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)




ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)




SELECT *
FROM Portfolio.dbo.NashvilleHousing





----------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as vacant" field




SELECT DISTINCT(SoldAsVacant)
FROM NashvilleHousing



SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2




SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Portfolio.dbo.NashvilleHousing




UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END




SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2




-------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
		PropertyAddress, 
		SalePrice, 
		SaleDate, 
		LegalReference
		ORDER BY 
			UniqueID) row_num
FROM Portfolio.dbo.NashvilleHousing
--ORDER BY ParcelID
)

SELECT * -- To ultimately delete duplicates, delete the select(SELECT *) statement, then replace it with DELETE
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



SELECT * 
FROM Portfolio.dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------------

-- Delete unused columns



SELECT *
FROM Portfolio.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
