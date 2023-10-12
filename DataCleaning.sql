---------------------------------------------------------------------------------------------------------------------------------
--DATA CLEANING
SELECT *
FROM NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------
--1. STANDARDIZING THE DATE FORMAT

SELECT SaleDate,
	   CONVERT(Date, SaleDate)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date;


---------------------------------------------------------------------------------------------------------------------------------
--2. POPULATING THE PROPERTY ADDRESS DATA

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT  A.ParcelID, A.PropertyAddress, B.ParcelID, A.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing A
JOIN NashvilleHousing B
	ON A.ParcelID = B.ParcelID AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing A
JOIN NashvilleHousing B
	ON A.ParcelID = B.ParcelID AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


---------------------------------------------------------------------------------------------------------------------------------
--3a. BREAKING OUT PROPERTY ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT * --PropertyAddress
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))  AS Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255),
	PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ),
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


---------------------------------------------------------------------------------------------------------------------------------
--3b. BREAKING OUT OWNER ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)
SELECT OwnerAddress
FROM NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnwerSplitAddress Nvarchar(255),
	OwnwerSplitCity Nvarchar(255),
	OwnwerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnwerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	OwnwerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	OwnwerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
	

---------------------------------------------------------------------------------------------------------------------------------
--4. CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD

SELECT DISTINCT (SoldAsVacant)
FROM NashvilleHousing

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = (CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END)


 ---------------------------------------------------------------------------------------------------------------------------------
--5. REMOVING DUPLICATES

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM NashvilleHousing
--ORDER BY ParcleID
)
--DELETE 
SELECT *
FROM RowNumCTE
WHERE Row_num > 1
--ORDER BY PropertyAddress


---------------------------------------------------------------------------------------------------------------------------------
--6. DELETING UNUSED COLUMNS
SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
