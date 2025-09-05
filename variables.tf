/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

variable "metadata" {
  type = any
}

/*----------------------------------------------------------------------*/
/* S3_backend | Variable Definition                                     */
/*----------------------------------------------------------------------*/
variable "s3_backend_parameters" {
  type        = any
  description = "s3_backend parameteres"
  default     = {}
}

variable "s3_backend_defaults" {
  type        = any
  description = "s3_backend default parameteres"
  default     = {}
}
