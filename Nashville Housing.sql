/* Cleaning data with SQL */

-- 1.
-- Standarize date format

SELECT SaleDateConverted,
       CONVERT (Date, SaleDate)
FROM   nashvillehousing


UPDATE nashvillehousing 
SET    SaleDate = CONVERT(Date, SaleDate)


ALTER TABLE nashvillehousing
ADD         SaleDateConverted Date      

UPDATE nashvillehousing 
SET    SaleDateConverted = CONVERT(Date, SaleDate)

-- 2.
-- Populate property adress data

SELECT *
FROM   nashvillehousing
--WHERE  PropertyAddress IS NULL
ORDER BY  ParcelID


SELECT a.parcelID,
       a.propertyAddress,
	   b.parcelID,
	   b.propertyAddress,
	   ISNULL (a.propertyAddress, b.propertyAddress)
FROM   nashvillehousing a
jOIN   nashvillehousing b ON  a.ParcelID = b.parcelID
                          AND a.UniqueID <> b.UniqueID
WHERE  a.PropertyAddress  IS NULL

UPDATE a
SET    PropertyAddress = ISNULL (a.propertyAddress, b.propertyAddress)
FROM   nashvillehousing a
jOIN   nashvillehousing b ON  a.ParcelID = b.parcelID
                          AND a.UniqueID <> b.UniqueID
WHERE  a.PropertyAddress  IS NULL

-- 3.
-- Breaking down Address into individual columns (Adress, City, State)

SELECT PropertyAddress
FROM   nashvillehousing


SELECT PropertyAddress,
       SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1) AS Address,
	   SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) +1, LEN (PropertyAddress)) AS City
FROM   nashvillehousing


ALTER TABLE nashvillehousing
ADD         PropertySplitAdress Nvarchar (255)

UPDATE nashvillehousing
SET    PropertySplitAdress = SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1) 


ALTER TABLE nashvillehousing
ADD         PropertySplitCity Nvarchar (255)

UPDATE nashvillehousing
SET    PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) +1, LEN (PropertyAddress)) 

SELECT *
FROM   nashvillehousing

-- Spliting OwnerAddress into individual columns (Address, City, State)

SELECT OwnerAddress
FROM   nashvillehousing


SELECT OwnerAddress,
       PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3),
	   PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2),
	   PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)
FROM   nashvillehousing


ALTER TABLE nashvillehousing
ADD         OwnerSplitAddress Nvarchar (255)

UPDATE nashvillehousing
SET    OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE nashvillehousing
ADD         OwnerSplitCity Nvarchar (255)

UPDATE nashvillehousing
SET    OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE nashvillehousing
ADD         OwnerSplitState Nvarchar (255)

UPDATE nashvillehousing
SET    OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM   nashvillehousing


-- 4.
-- Change Y and N to YES and no in 'Sold AS Vacant' field

SELECT   DISTINCT (SoldAsVacant), 
         COUNT (SoldAsVacant)
FROM     nashvillehousing
GROUP BY SoldAsVacant
ORDER BY COUNT (SoldAsVacant)


SELECT SoldAsVacant,
       CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	        WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
	   END
FROM   nashvillehousing

UPDATE nashvillehousing
SET    SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	                       WHEN SoldAsVacant = 'N' THEN 'No'
			               ELSE SoldAsVacant
	                  END


-- 5.
-- Remove Duplication

WITH RowNumCTE AS  
(
SELECT *,
       ROW_NUMBER () OVER (PARTITION BY ParcelID,
	                                    PropertyAddress,
								 		SaleDate,
								  		SalePrice,
								  	    LegalReference
							ORDER BY    ParcelID) row_num
FROM   nashvillehousing
)

SELECT *
FROM   RowNumCTE
WHERE  row_num > 1
--ORDER BY PropertyAddress


-- 6.
-- Delete unsued columns

SELECT *
FROM   nashvillehousing

ALTER TABLE nashvillehousing
DROP COLUMN SaleDate,
            PropertyAddress,
			OwnerAddress,
			TaxDistrict