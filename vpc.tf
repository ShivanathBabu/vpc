resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    }
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = local.az-names[count.index]
  map_public_ip_on_launch = true
  tags = merge(
    var.public_subnet_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-public-${local.az-names[count.index]}"
    }
  )

}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = local.az-names[count.index]
  tags = merge(
    var.private_subnet_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-private-${local.az-names[count.index]}"
    }
  )
}

resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  availability_zone = local.az-names[count.index]
  tags = merge(
    var.database_subnet_tags,
    local.common_tags,
    {
         Name = "${var.project}-${var.environment}-database-${local.az-names[count.index]}"
    }
  )
}

# elastic ip

resource "aws_eip" "nat" {
  domain = "vpc"
  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    }
  )
}

# nat gateway

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public[0].id
  tags = merge(
    var.nat_gateway_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    }
  )
  depends_on = [aws_internet_gateway.main]
}

#route table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-public"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-private"
    }
  )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-database"
    }
  )
}


# routing nat gateway to internet

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.main.id
}

# routing private to nat

resource "aws_route" "name" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id

}

#associating
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
    count = length(var.database_subnet_cidrs)
  subnet_id = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}