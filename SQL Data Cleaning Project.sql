/*

Cleaning Data in SQL Queries

*/

SELECT * FROM nashville_housing;

-- Populate Property Address data
SELECT *
FROM nashville_housing
ORDER BY parcelid;

SELECT
	a.parcelid,
	a.propertyaddress,
	b.parcelid,
	b.propertyaddress,
	COALESCE(a.propertyaddress,b.propertyaddress)
FROM nashville_housing a
JOIN nashville_housing b
	ON a.parcelid=b.parcelid
	AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL;

UPDATE nashville_housing a
SET propertyaddress=COALESCE(a.propertyaddress,b.propertyaddress)
FROM nashville_housing b
WHERE
	a.parcelid=b.parcelid
	AND a.uniqueid <> b.uniqueid
	AND a.propertyaddress IS NULL;

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT
	propertyaddress
FROM nashville_housing;

SELECT
SUBSTRING(propertyaddress,1,POSITION(',' IN propertyaddress)-1) AS address,
SUBSTRING(propertyAddress, POSITION(',' IN PropertyAddress) + 1) AS address
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD propertysplitaddress varchar (255);

UPDATE nashville_housing
SET propertysplitaddress= SUBSTRING(propertyaddress,1,POSITION(',' IN propertyaddress)-1);

ALTER TABLE nashville_housing
ADD propertysplitcity varchar (255);

UPDATE nashville_housing
SET propertysplitcity=SUBSTRING(propertyAddress, POSITION(',' IN PropertyAddress) + 1);

SELECT *
FROM nashville_housing;

SELECT
	owneraddress
FROM nashville_housing;

SELECT
SPLIT_PART(REPLACE(owneraddress,',','.'),'.',1),
SPLIT_PART(REPLACE(owneraddress,',','.'),'.',2),
SPLIT_PART(REPLACE(owneraddress,',','.'),'.',3)
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD ownersplitaddress varchar (255);

UPDATE nashville_housing
SET ownersplitaddress= SPLIT_PART(REPLACE(owneraddress,',','.'),'.',1);

ALTER TABLE nashville_housing
ADD ownersplitcity varchar (255);

UPDATE nashville_housing
SET ownersplitcity=SPLIT_PART(REPLACE(owneraddress,',','.'),'.',2);

ALTER TABLE nashville_housing
ADD ownersplitstate varchar (255);

UPDATE nashville_housing
SET ownersplitstate=SPLIT_PART(REPLACE(owneraddress,',','.'),'.',3);

SELECT *
FROM nashville_housing;



-- Change True and False to Yes and No in "Sold as Vacant" field
SELECT
	DISTINCT(soldasvacant),
	COUNT(soldasvacant)
FROM nashville_housing
GROUP BY soldasvacant
ORDER BY 2;

ALTER TABLE nashville_housing
ALTER COLUMN soldasvacant TYPE varchar;

SELECT
soldasvacant,
CASE
	WHEN soldasvacant= 'false' THEN 'No'
	WHEN soldasvacant= 'true' THEN 'Yes' 
ELSE soldasvacant
END
FROM nashville_housing;

UPDATE nashville_housing
SET soldasvacant= 
CASE
	WHEN soldasvacant= 'false' THEN 'No'
	WHEN soldasvacant= 'true' THEN 'Yes' 
	ELSE soldasvacant
END


-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY
		parcelid,
		propertyaddress,
		saleprice,
		saledate,
		legalreference
		ORDER BY
			uniqueid
				) row_num
FROM nashville_housing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY propertyaddress;

DELETE FROM nashville_housing
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT ctid,
            ROW_NUMBER() OVER (
                PARTITION BY
                    parcelid,
                    propertyaddress,
                    saleprice,
                    saledate,
                    legalreference
                ORDER BY
                    uniqueid
            ) AS row_num
        FROM nashville_housing
    ) subquery
    WHERE row_num > 1
);

-- Delete Unused Columns
ALTER TABLE nashville_housing
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict,
DROP COLUMN propertyaddress;