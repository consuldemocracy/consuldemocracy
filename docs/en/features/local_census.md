# Local census

This feature is designed for installations with limited resources that cannot configure and customize their census connection remotely, so we offer them a solution to use a local census instead. For this purpose, administrators are provided with a way to manage the local census database through the administration panel under **Settings > Local census**.

## Managing the local census

Administrators can manage this census in two different ways:

* **Manually**: adding one citizen at a time through a form.
* **Automatically**: through an importation process.

### Manually

Administrators can create a record by clicking the _Create new local census record_ button, which appears in the top right corner of the page. This will take us to a new page where we can fill in the following form and create the new record:

![Form to create a record by filling in the document type, document number, date of birth and postal code](../../img/local_census/add-local-census-record-en.png)

### Automatically

Administrators can import multiple records through a CSV file by clicking the _Import CSV_ button, which appears in the top right corner of the page. This will take us to a new page where we can attach a CSV file to create the new records:

![Page to import new records via csv](../../img/local_census/add-local-census-records-csv-en.png)

## Features

* Search by document number: Since the local census could contain a lot of records, we have added a search feature to allow administrators to find existing records by document number.

* Avoid the introduction of duplicated records: A model validation has been added that does not allow adding records that share the same _number_ and _type_ of document.
