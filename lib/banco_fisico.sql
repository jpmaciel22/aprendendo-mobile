create table if not exists Medico(
cpf varchar(11) primary key not null unique,
email varchar(100) not null unique,
password text not null,
regiao varchar(150) not null,
telefone varchar(11) not null,
nome varchar(60) not null
);

create table if not exists "User"(
cpf varchar(11) primary key not null unique,
email varchar(100) not null unique,
password text not null,
telefone varchar(11) not null,
nome varchar(60) not null
);

create table if not exists EnderecoMedico(
id_endereco serial primary key,
rua varchar(60) not null,
cidade varchar(60) not null,
estado varchar(30) not null,
id_medico varchar(11) not null,
foreign key (id_medico) references Medico(cpf)
);

drop table UserEndereco;

create table if not exists UserEndereco(
id_end serial primary key,
rua varchar(60) not null,
cidade varchar(60) not null,
estado varchar(30) not null,
id_user varchar(11) not null,
foreign key (id_user) references "User"(cpf)
);

create table if not exists Servico(
id_servico serial primary key,
id_medico varchar(11) not null,
foreign key (id_medico) references Medico(cpf)
);

create table if not exists ConsultaAgenda(
codigo serial primary key,
horario timestamp with time zone not null,
id_user varchar(11) not null,
id_medico varchar(11) not null,
foreign key (id_user) references "User"(cpf),
foreign key (id_medico) references Medico(cpf)
);