# Local Census

To provide to administrator users a way to manage the local census database through the administration panel **Settings &gt; Manage local census**. Currently the only way to manipulate this table records is through the rails console.

Allow adiministrators users to manage this table in two different ways:

* **Manually**: one by one through a CRUD interface.
* **Automatically**: through an importation process.

## Manually

Provide a way to manage local census records to administrator users through administration interface.

* Local Census Page

  ![Manage local census](../../.gitbook/assets/manage-local-census-en.png)

* Add new record

  ![Create local census record](../../.gitbook/assets/add-local-census-record-en.png)

Features:

1. Search by document\_number: As local\_census\_records could contain a lot of records we have added a search feature to allow administrators to find existing records by document\_number.
2. Avoid the introduction of duplicated records: A model validation has been added to the following attributes pair \[:document\_number, :document\_type\]

## Automatically

Allow administrator users to import local census records though CSV file.

* Local Census Page ![Manage local census csv](../../.gitbook/assets/manage-local-census-csv-en%20%281%29.png)
* Import CSV ![Create local census records csv](../../.gitbook/assets/add-local-census-records-csv-en.png)

